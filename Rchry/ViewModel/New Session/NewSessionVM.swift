//
//  NewSessionVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 23..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

class NewSessionVM {
    
    private let sessionService: SessionService
    private let errorMapper: DatabaseErrorToMessageMapper
    private let dateProvider: DateProvider
    
    private let ownerTarget: Target!
    
    private var guests = Variable([String]())
    private var shouldTrackUser = Variable(true)
    private var name = Variable("")
    
    private let disposeBag = DisposeBag()
    
    init(ownerTarget: Target,
         sessionService: SessionService = FirebaseSessionService(),
         errorMapper: DatabaseErrorToMessageMapper = BasicDatabaseErrorToMessageMapper(),
         dateProvider: DateProvider = BasicDateProvider()) {
        
        self.ownerTarget = ownerTarget
        self.sessionService = sessionService
        self.errorMapper = errorMapper
        self.dateProvider = dateProvider
    }
    
    func setup(newGuestAdded: Observable<String>,
         availableGuestAdded: Observable<String>,
         guestRemoved: Observable<Int>,
         nameChanged: Observable<String>,
         userTrackingChanged: Observable<Bool>) {
        
        setup(newGuestAdded: newGuestAdded)
        setup(availableGuestAdded: availableGuestAdded)
        setup(guestRemoved: guestRemoved)
        setup(nameChanged: nameChanged)
        setup(userTrackingChanged: userTrackingChanged)
    }
    
    private func setup(newGuestAdded: Observable<String>) {
        newGuestAdded
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0 != ""}
            .filter { [unowned self] in !self.guests.value.contains($0) }
            .subscribe(onNext: { [unowned self] in self.guests.value.append($0) })
            .disposed(by: disposeBag)
    }
    
    private func setup(availableGuestAdded: Observable<String>) {
        availableGuestAdded
            .filter { [unowned self] in !self.guests.value.contains($0) }
            .subscribe(onNext: { [unowned self] in self.guests.value.append($0) })
            .disposed(by: disposeBag)
    }
    
    private func setup(guestRemoved: Observable<Int>) {
        guestRemoved
            .subscribe(onNext: { [unowned self] index in
                self.guests.value.remove(at: index)
            })
            .disposed(by: disposeBag)
    }
    
    private func setup(nameChanged: Observable<String>) {
        nameChanged
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .bind(to: name)
            .disposed(by: disposeBag)
    }
    
    private func setup(userTrackingChanged: Observable<Bool>) {
        userTrackingChanged
            .bind(to: shouldTrackUser)
            .disposed(by: disposeBag)
    }
    
    var guestsDatasource: Observable<[String]> {
        return guests.asObservable()
    }
        
    func createSession(reactingToShouldTrackMyScore observable: Observable<Bool>) -> Observable<(Session?, String?)> {
        return observable
            .flatMap { [unowned self] shouldTrackMyScore -> Observable<(Session?, String?)> in
                var users = self.guests.value
                if shouldTrackMyScore {
                    users.append(ShotNames.MY_SCORE )
                }
                let session = Session(ownerTarget: self.ownerTarget, name: self.name.value, timestamp: self.dateProvider.currentTimestamp, shotsByUser: users.reduce([String: [Float]]()) { result, user in
                    var result = result
                    result[user] = [Float()]
                    return result
                })
                return self.sessionService.create(session: session)
                    .map { ($0, nil) }
                    .catchError { error in
                        return Observable.just((nil, self.errorMapper.map(error: error as! DatabaseError)))
                }
        }
    }
    
    var savedGuestsArray = [String]()
    
    var savedGuestsDatasource: Observable<([String]?, String?)> {
        return sessionService.observeGuests()
            .do(onNext: { [unowned self] in self.savedGuestsArray = $0 })
            .map { ($0, nil) }
            .catchError { [unowned self] in Observable.just((nil, self.errorMapper.map(error: $0 as! DatabaseError))) }
    }
    
    var isFormReady: Observable<Bool> {
        return Observable.combineLatest(guests.asObservable(), shouldTrackUser.asObservable(), resultSelector: { guests, shouldTrackUser in
            return guests.count > 0 || shouldTrackUser
        })
    }
}

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
    
    private var sessionService: SessionService
    private var errorMapper: DatabaseErrorToMessageMapper
    
    private let disposeBag = DisposeBag()
    
    private var ownerTarget: Target
    private var guests = Variable([String]())
    private var name = Variable("")
    
    init(ownerTarget: Target,
         newGuestAdded: Observable<String>,
         addedGuestRemoved: Observable<Int>,
         nameChanged: Observable<String>,
         sessionService: SessionService = FirebaseSessionService(),
         errorMapper: DatabaseErrorToMessageMapper = BasicDatabaseErrorToMessageMapper()) {
        self.sessionService = sessionService
        self.errorMapper = errorMapper
        
        self.ownerTarget = ownerTarget
        
        newGuestAdded
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0 != ""}
            .filter { [unowned self] in !self.guests.value.contains($0) }
            .subscribe(onNext: { [unowned self] in self.guests.value.append($0) })
            .disposed(by: disposeBag)
        
        addedGuestRemoved
            .subscribe(onNext: { [unowned self] index in
                self.guests.value.remove(at: index)
            })
            .disposed(by: disposeBag)
        
        nameChanged
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .bind(to: name)
            .disposed(by: disposeBag)
    }
    
    var guestsDatasource: Observable<[String]> {
        return guests.asObservable()
    }
    
    var isSessionReady: Observable<Bool> {
        return name.asObservable().map { $0 != "" }
    }
    
    func createSession(reactingTo observable: Observable<()>) -> Observable<(Session?, String?)> {
        return observable
            .flatMap { [unowned self] _ -> Observable<(Session?, String?)> in
                let session = Session(ownerTarget: self.ownerTarget, name: self.name.value, guests: self.guests.value)
                return self.sessionService.create(session: session)
                    .map { ($0, nil) }
                    .catchError { error in
                        return Observable.just((nil, self.errorMapper.map(error: error as! DatabaseError)))
                }
        }
    }
}

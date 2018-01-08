//
//  NewTargetVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 03..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

struct NewTargetVM {
    
    let scoresSubVM: ScoresSubVM
    let pickAnIconSubVM: PickAnIconSubVM
    
    private let targetService: TargetService
    
    private var name = Variable<String>("")
    private var distance = Variable<String>("")
    private var targetExists = Variable<Bool>(false)

    private let disposeBag = DisposeBag()
    
    init(targetService: TargetService = FirebaseTargetService(), scoresSubVM: ScoresSubVM = ScoresSubVM(), pickAnIconSubVM: PickAnIconSubVM = PickAnIconSubVM()) {
        self.targetService = targetService
        self.scoresSubVM = scoresSubVM
        self.pickAnIconSubVM = pickAnIconSubVM
        observeNameAndDistance()
    }
    
    private func observeNameAndDistance() {
        Observable<(name: String, distance: String)>.combineLatest(name.asObservable(), distance.asObservable(), resultSelector: {
            (name: $0, distance: $1)
        })
        .filter({ $0.name != "" && $0.distance != "" })
        .debounce(0.3, scheduler: MainScheduler.instance)
        .subscribe(onNext: {
            self.doesTargetExist(withName: $0.name, andWithDistance: $0.distance)
                .bind(to: self.targetExists)
                .disposed(by: self.disposeBag)
        }, onError: nil, onCompleted: nil, onDisposed: { print("disposed") })
        .disposed(by: disposeBag)
    }
    
    func bindName(fromObservable observable: Observable<String?>) {
        observable
            .map({ return $0 == nil ? "" : $0!})
            .bind(to: name)
            .disposed(by: disposeBag)
    }
    
    func bindDistance(fromObservable observable: Observable<String?>) {
        observable
            .map({ return $0 == nil ? "" : $0!})
            .bind(to: distance)
            .disposed(by: disposeBag)
    }
    
    func bindTargetExists(toObserver observer: AnyObserver<Bool>) {
        targetExists.asObservable()
            .map { !$0 }
            .bind(to: observer)
            .disposed(by: disposeBag)
    }
    
    func createTarget() {
        targetService.create(target: Target(name: "Target", distance: 15.2, scores: [0, 5, 8, 10, 11], icon: "target", shots: 0)).subscribe(onError: { error in
            print("An error happened while creating target: \(error).")
        }, onCompleted: {
            print("Target succesfully created.")
        }).disposed(by: disposeBag)
    }
    
    func doesTargetExist(withName name: String, andWithDistance distance: String) -> Observable<Bool> {
        if let distanceFloat = distance.float() {
            return targetService.doesTargetExist(withName: name, andWithDistance: distanceFloat)
        }
        return Observable<Bool>.error(DatabaseError.other)
    }
}

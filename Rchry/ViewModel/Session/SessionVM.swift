//
//  SessionVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 25..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

class SessionVM {
    
    private let shotService: ShotService
    
    private let session: Session
    
    private var _shots = Variable([Shot]())
    private let disposeBag = DisposeBag()
    
    init(session: Session, shotService: ShotService = FirebaseShotService()) {
        self.session = session
        self.shotService = shotService
        setupInitialShot()
    }
    
    private func setupInitialShot() {
        addShot(withIndex: 0)
    }
    
    private func addShot(withIndex index: Int) {
        var scores = Shot.ScoresByUser()
        if session.trackUserScore {
            scores.append((ShotNames.MY_SCORE, nil))
        }
        scores = session.guests.reduce(into: scores, { scores, guest in
            scores.append((guest, nil))
        })
        let shot = Shot(index: index, scores: scores, active: true)
        _shots.value.append(shot)
    }
    
    var possibleScores: [Float] {
        return session.ownerTarget.scores
    }
    
    var shotsDatasource: Observable<[Shot]> {
        return _shots.asObservable()
    }
    
    func saveLatestShot(reactingTo observable: Observable<Shot>) {
        observable
            .flatMap { self.shotService.add(shot: $0, forSession: self.session) }
            .retry(3)
            .subscribe(onNext: { _ in
                if let index = self._shots.value.last?.index {
                    // .last is get only, that's why this is uglier than should be
                    self._shots.value[self._shots.value.count-1].active = false
                    self.addShot(withIndex: index)
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    func setShotActiveness(reactingTo observable: Observable<Int>) {
        observable
            .subscribe(onNext: { [unowned self] index in
                self._shots.value[index].active = !self._shots.value[index].active
            })
            .disposed(by: disposeBag)
    }
}







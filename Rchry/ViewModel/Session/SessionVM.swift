//
//  SessionVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 25..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

// A session starts with 1 shot at index 0, called Shot 1.
// It doesn't have any scores selected.
// Then the user can select a score for himself and the guests.
// When every user has a score set, 2 things happen:
// 1. The shot turns ready (this can happen only once) -> the session vm subs to this, and creates a new shot with index + 1 (again, no scores selected)
// 2. The shot turns to active == false. -> The shot only shows the header in the ui.
// A shot can change its activenss by tapping the header. This shows/hides the scores.
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
    
    func addShot(withIndex index: Int) {
        var scores = Shot.ScoresByUser()
        if session.trackUserScore {
            scores.append((ShotNames.MY_SCORE, nil))
        }
        scores = session.guests.reduce(into: scores, { scores, guest in
            scores.append((guest, nil))
        })
        _shots.value.append(Shot(index: index, scores: scores, active: true))
        _shots.value[_shots.value.count - 1].shotReady
            .subscribe(onNext: { [unowned self] _ in
                self.addShot(withIndex: self._shots.value.count)
            })
            .disposed(by: disposeBag)
        print("created new empty shot with index \(index)")
    }
    
    var possibleScores: [Float] {
        return session.ownerTarget.scores
    }
    
    var shotsDatasource: Observable<[Shot]> {
        return _shots.asObservable()
    }
    
    // This is set by tapping the header -> hide/show scores by users
    func setShotActiveness(reactingTo observable: Observable<Int>) {
        observable
            .subscribe(onNext: { [unowned self] index in
                print("header was tapped so activeness changed at \(index) to \(!self._shots.value[index].active)")
                self._shots.value[index].active = !self._shots.value[index].active
            })
            .disposed(by: disposeBag)
    }
    
    // This is set by the user's score cell, when a new score is tapped
    func setScoreByUserAndIndex(reactingTo observable: Observable<(Float, String, Int)>, disposedBy disposeBag: DisposeBag? = nil)  {
        observable
            .subscribe(onNext: { [unowned self] scoreByUserAndIndex in
                let index = scoreByUserAndIndex.2
                let user = scoreByUserAndIndex.1
                let score: Float? = scoreByUserAndIndex.0
                
                self._shots.value[index].addScore(score, byUser: user)
                print("score was set for \(user) to \(score ?? -1) for shot \(index)")
            })
            .disposed(by: disposeBag ?? self.disposeBag)
    }
}







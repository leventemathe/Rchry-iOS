//
//  Shot.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 26..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

class Shot {
    
    // I need this ordered so the users are always in the same order in a list of shots,
    // so I can't use dictionary
    typealias ScoresByUser = [(String, Float?)]
    
    let index: Int
    let title: String
    // Should the UI show this shot?
    var active: Bool
    
    private var _scores: Variable<ScoresByUser>
    
    private let disposeBag = DisposeBag()
    
    var scores: ScoresByUser {
        return _scores.value
    }
    
    // When all the scores are selected, emit a shot ready event, then complete.
    // It should emit only once, as this can happen only once.
    // It should be subscribed to to get notified when a new shot can be added.
    // So SessionVM subs to it.
    private var _shotReady = PublishSubject<Void>()
    
    var shotReady: Observable<Void> {
        return _shotReady.asObservable()
    }
    
    init(index: Int, scores: ScoresByUser, active: Bool) {
        self.index = index
        let titleFormat = NSLocalizedString("Shot%d", comment: "Index of shot for a session.")
        self.title = String.localizedStringWithFormat(titleFormat, index + 1)
        self._scores = Variable(scores)
        self.active = active
        
        setupSendShotReadyBasedOnScoresFilled()
        setupActivenessBasedOnScoresFilled()
    }
    
    // Emit an event (then complete) when all users have selected a score.
    // Because you can't unselect scores, this should be sent only once, then it should complete.
    private func setupSendShotReadyBasedOnScoresFilled() {
        _scores.asObservable()
            .subscribe(onNext: { [unowned self] scoresByUser in
                var ready = true
                for scoreByUser in scoresByUser {
                    if scoreByUser.1 == nil {
                        ready = false
                        break
                    }
                }
                if ready {
                    self._shotReady.onNext(())
                    self._shotReady.onCompleted()
                }
            })
            .disposed(by: disposeBag)
    }
    
    // This observes the shots, and when every user has a shot set, it changes the activeness to false.
    // This happens only once, similar to shotReady.
    // This should hide the cells in the ui.
    
    // TODO: this should stop observing when all the scores are selected, just like ready
    private func setupActivenessBasedOnScoresFilled() {
        _scores.asObservable()
            .subscribe(onNext: { scoresByUser in
                var active = false
                for scoreByUser in scoresByUser {
                    if scoreByUser.1 == nil {
                        active = true
                        break
                    }
                }
                if !active {
                    print("all the scores were selected, so activeness changed to false")
                }
                self.active = active
            })
            .disposed(by: disposeBag)
    }
    
    func addScore(_ score: Float?, byUser user: String) {
        if let scoreByUserIndex = scores.index(where: { (foundUser, _  ) in
            return user == foundUser
        }) {
            _scores.value[scoreByUserIndex] = (user, score)
        }
    }
}

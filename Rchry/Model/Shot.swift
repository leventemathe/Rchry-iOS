//
//  Shot.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 26..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

// Never again put rx code into the model.
// Set the reactive behaviour outside.
// Problem: when you create a new object, the rx code is setup wether you want it or not.
class Shot {
    
    // I need this ordered so the users are always in the same order in a list of shots,
    // so I can't use dictionary
    typealias ScoresByUser = [(String, Float?)]
    
    let index: Int
    let title: String
    // Should the UI show this shot?
    private var _active: Bool
    
    var active: Bool {
        return _active
    }
    
    private var _scores: Variable<ScoresByUser>
    
    private let disposeBag = DisposeBag()
    
    var scores: ScoresByUser {
        return _scores.value
    }
    
    // When all the scores are selected, emit a shot ready event, then complete.
    // It should emit only once, as this can happen only once.
    // It should be subscribed to to get notified when a new shot can be added.
    // So SessionVM subs to it.
    private var _shotReadySubject = PublishSubject<Void>()
    
    var shotReadyObservable: Observable<Void> {
        return _shotReadySubject.asObservable()
    }
    
    private var _shotReady = false
    
    var shotReady: Bool {
        return _shotReady
    }
    
    init(index: Int, scores: ScoresByUser, active: Bool, shotReady: Bool = false) {
        self.index = index
        let titleFormat = NSLocalizedString("Shot%d", comment: "Index of shot for a session.")
        self.title = String.localizedStringWithFormat(titleFormat, index + 1)
        self._scores = Variable(scores)
        self._active = active
        self._shotReady = shotReady
        
        // The order here is important! Activeness needs to be set before readyness, so that when the event arrives in the collection view, it's already set.
        setupActivenessBasedOnScoresFilled()
        setupSendShotReadyBasedOnScoresFilled()
    }
    
    // Emit an event (then complete) when all users have selected a score.
    // Because you can't unselect scores, this should be sent only once, then it should complete.
    private func setupSendShotReadyBasedOnScoresFilled() {
        if shotReady {
            return
        }
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
                    self._shotReady = true
                    self._shotReadySubject.onNext(())
                    self._shotReadySubject.onCompleted()
                }
            })
            .disposed(by: disposeBag)
    }
    
    // This observes the shots, and when every user has a shot set, it changes the activeness to false.
    // This happens only once, similar to shotReady.
    // This should hide the cells in the ui.
    var activenessBasedOnScoresFilledSubscription: Disposable!
    
    private func setupActivenessBasedOnScoresFilled() {
        if shotReady {
            return
        }
        activenessBasedOnScoresFilledSubscription = _scores.asObservable()
            .subscribe(onNext: { [unowned self] scoresByUser in
                var active = false
                for scoreByUser in scoresByUser {
                    if scoreByUser.1 == nil {
                        active = true
                        break
                    }
                }
                if !active {
                    //print("all the scores were selected, so activeness changed to false")
                    self.activenessBasedOnScoresFilledSubscription?.dispose()
                }
                self._active = active
            })
    }
    
    func addScore(_ score: Float?, byUser user: String) {
        if let scoreByUserIndex = scores.index(where: { (foundUser, _  ) in
            return user == foundUser
        }) {
            _scores.value[scoreByUserIndex] = (user, score)
        }
    }
}

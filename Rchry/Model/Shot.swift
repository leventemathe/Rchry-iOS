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
    var active: Bool
    
    private var _scores: Variable<ScoresByUser>
    
    private let disposeBag = DisposeBag()
    
    var scores: ScoresByUser {
        return _scores.value
    }
    
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

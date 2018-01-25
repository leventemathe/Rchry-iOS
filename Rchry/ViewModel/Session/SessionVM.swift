//
//  SessionVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 25..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

struct SessionSection {
    
    typealias ScoresByUser = [(String, Float)]
    
    var index: Int
    var title: String
    var scoresByUser: ScoresByUser
    var score: Float?
    var active: Bool
    
    init(index: Int, title: String, scoresByUser: ScoresByUser, active: Bool) {
        self.index = index
        self.title = title
        self.scoresByUser = scoresByUser
        self.active = active
    }
}

class SessionVM {
    
    private let disposeBag = DisposeBag()
    
    private var _possibleScores = Variable<[Float]>([0, 5, 8, 10, 11])
    private var _scores = Variable([
        SessionSection(index: 0, title: "Shot 1", scoresByUser: [("My score", 5), ("apa", 8)], active: false),
        SessionSection(index: 1, title: "Shot 2", scoresByUser: [("My score", 8), ("apa", 5)], active: true)
    ])
    
    var possibleScores: Observable<[Float]> {
        return _possibleScores.asObservable()
    }
    
    var scores: Observable<[SessionSection]> {
        return _scores.asObservable()
    }
    
    func changeShotActiveness(reactingTo observable: Observable<Int>) {
        observable
            .subscribe(onNext: { [unowned self] in
                self._scores.value[$0].active = !self._scores.value[$0].active
                print("activeness changed at \($0) to \(self._scores.value[$0].active)")
            })
            .disposed(by: disposeBag)
    }
}

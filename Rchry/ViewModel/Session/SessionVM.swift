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
    
    typealias ScoreByUser = [(String, Float)]
    
    var index: Int
    var title: String
    var scoresByUser: ScoreByUser?
    var active: Bool
    
    init(index: Int, title: String, active: Bool, scoreByUser: ScoreByUser = []) {
        self.index = index
        self.title = title
        self.scoresByUser = scoreByUser
        self.active = active
    }
}

class SessionVM {
    
    private let disposeBag = DisposeBag()
    
    private var _possibleScores = Variable<[Float]>([0, 5, 8, 10, 11])
    private var _scores = Variable([
        SessionSection(index: 0, title: "Shot 1", active: false, scoreByUser: [("My score", 5), ("apa", 8)]),
        SessionSection(index: 1, title: "Shot 2", active: true, scoreByUser: [("My score", 8), ("apa", 5)])
    ])
    private var _activeness: PublishSubject<Int>?
    
    var possibleScores: Observable<[Float]> {
        return _possibleScores.asObservable()
    }
    
    var scoresDatasource: Observable<[SessionSection]> {
        return _scores.asObservable()
    }
    
    func changeShotActiveness(reactingTo observable: Observable<Int>) {
        observable
            .subscribe(onNext: { [unowned self] in
                self._scores.value[$0].active = !self._scores.value[$0].active
            })
            .disposed(by: disposeBag)
    }
}

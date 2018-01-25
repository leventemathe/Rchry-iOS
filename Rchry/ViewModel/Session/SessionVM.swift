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
    
    var title: String
    var scores: [String: Float]
}

class SessionVM {
    
    private var _possibleScores = Variable<[Float]>([0, 5, 8, 10, 11])
    private var _scores = Variable([
        SessionSection(title: "Shot 0", scores: ["My score": 5, "apa": 8]),
        SessionSection(title: "Shot 0", scores: ["My score": 8, "apa": 5])
        ])
    
    var possibleScores: Observable<[Float]> {
        return _possibleScores.asObservable()
    }
    
    var scores: Observable<[SessionSection]> {
        return _scores.asObservable()
    }
}

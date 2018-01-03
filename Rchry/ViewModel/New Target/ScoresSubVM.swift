//
//  ScoresVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 03..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

class ScoresSubVM {
    
    private var _scores = [Int]()
    
    var scores: [Int] {
        return _scores
    }
    
    func add(score: Int) -> Bool {
        if !_scores.contains(score) {
            _scores.append(score)
            return true
        }
        return false
    }
    
    func remove(score: Int) -> Bool {
        if let scoreIndex = _scores.index(of: score) {
            _scores.remove(at: scoreIndex)
            return true
        }
        return false
    }
    
    var count: Int {
        return _scores.count
    }
    
    subscript(index: Int) -> Int? {
        return _scores[index]
    }
}

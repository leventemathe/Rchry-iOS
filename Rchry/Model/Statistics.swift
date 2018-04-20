//
//  Statistics.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 04. 20..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import RxSwift

class Statistics {
    
    func calculateAverage(_ scores: [Float]) -> Float? {
        if scores.count < 1 {
            return nil
        }
        return (scores.reduce(0.0, { $0 + $1 })) / Float(scores.count)
    }
    
    func calculateMin(_ scores: [Float]) -> Float? {
        if scores.count < 1 {
            return nil
        }
        return scores.min()!
    }
    
    func calculateMax(_ scores: [Float]) -> Float? {
        if scores.count < 1 {
            return nil
        }
        return scores.max()!
    }
    
    func calculateDiff(_ scores: [Float]) -> Float? {
        if scores.count < 1 {
            return nil
        }
        return scores.max()! - scores.min()!
    }
}

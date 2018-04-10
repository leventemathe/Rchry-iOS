//
//  AverageScorePerUser.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 04. 10..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

struct AverageScorePerUser {
    
    let name: String
    let averageScore: Float
    
    init(name: String, scores: [Float]) {
        self.name = name
        averageScore = (scores.reduce(0) { $0 + $1 }) / Float(scores.count)
    }
}

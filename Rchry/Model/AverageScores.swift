//
//  AverageScore.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 04. 06..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

struct AverageScores {
    
    let user: String
    let scores: [(String, Float)]
    
    init(user: String, sessions: [Session]) {
        self.user = user
        self.scores = sessions.map { session in
            return (session.name, session.scores.reduce(0.0, { result, score in result + score }) / Float(session.scores.count))
        }
    }
}

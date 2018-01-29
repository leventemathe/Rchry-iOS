//
//  Shot.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 26..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

struct Shot {
    
    typealias ScoresByUser = [(String, Float?)]
    
    let index: Int
    let title: String
    var scores: ScoresByUser
    var active: Bool
    
    init(index: Int, scores: ScoresByUser, active: Bool) {
        self.index = index
        let titleFormat = NSLocalizedString("Shot%d", comment: "Index of shot for a session.")
        self.title = String.localizedStringWithFormat(titleFormat, index + 1)
        self.scores = scores
        self.active = active
    }
}

//
//  Session.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 23..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

struct Session {
    
    let ownerTarget: Target
    let name: String
    let timestamp: Double
    let shotsByUser: [String: [Float]]
    
    init(ownerTarget: Target, name: String, timestamp: Double, shotsByUser: [String: [Float]]) {
        self.ownerTarget = ownerTarget
        self.name = name
        self.timestamp = timestamp
        self.shotsByUser = shotsByUser
    }
}

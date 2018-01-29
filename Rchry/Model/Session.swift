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
    let guests: [String]
    let trackUserScore: Bool = true
    
    init(ownerTarget: Target, name: String, timestamp: Double, guests: [String]? = nil) {
        self.ownerTarget = ownerTarget
        self.name = name
        self.timestamp = timestamp
        if let guests = guests {
            self.guests = guests
        } else {
            self.guests = [String]()
        }
    }
}

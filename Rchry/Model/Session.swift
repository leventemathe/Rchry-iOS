//
//  Session.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 23..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

struct Session {
    
    let name: String
    let guests: [String]
    
    init(name: String, guests: [String]? = nil) {
        self.name = name
        if let guests = guests {
            self.guests = guests
        } else {
            self.guests = [String]()
        }
    }
}

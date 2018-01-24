//
//  Dates.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 24..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

protocol DateProvider {
    
    var currentTimestamp: Double { get }
}

struct BasicDateProvider: DateProvider {
    
    var currentTimestamp: Double {
        return Date().timeIntervalSince1970
    }
}

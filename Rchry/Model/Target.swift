//
//  Target.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 04..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit

struct Target: Codable {
    
    let name: String
    let distance: Float
    let scores: [Float]
    let icon: String
    var shots: Int
}

//
//  DistanceUnitConverter.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 18..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

struct DistanceUnitConverter {
    
    func convertYardsToMeters(_ yards: Float) -> Float {
        return yards * 0.9144
    }
}

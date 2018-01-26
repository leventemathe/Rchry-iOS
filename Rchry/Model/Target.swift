//
//  Target.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 04..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit

enum DistanceUnit {
    
    static let STRING_METER = NSLocalizedString("DistanceUnitStringMeter", comment: "Meters")
    static let STRING_YARD = NSLocalizedString("DistanceUnitStringYard", comment: "Yards")
    
    case meter
    case yard
    
    func toString() -> String {
        switch self {
        case .meter:
            return DistanceUnit.STRING_METER
        case .yard:
            return DistanceUnit.STRING_YARD
        }
    }
    
    func toShortString() -> String {
        switch self {
        case .meter:
            return "m"
        case .yard:
            return "yd"
        }
    }
}

extension String {
    
    func toDistanceUnit() -> DistanceUnit? {
        switch self {
        case DistanceUnit.STRING_METER:
            return DistanceUnit.meter
        case DistanceUnit.STRING_YARD:
            return DistanceUnit.yard
        default:
            return nil
        }
    }
}

struct Target {
    
    let name: String
    let distance: Float
    let preferredDistanceUnit: DistanceUnit
    let scores: [Float]
    let icon: String
    let timestamp: Double
    var shots: Int
}

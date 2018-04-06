//
//  TargetVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 23..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

struct TargetVM {
    
    let target: Target
    
    func buildTitle() -> String {
        return target.name +
            " " +
            (target.distance.prettyString() ?? "") +
            " " +
            target.preferredDistanceUnit.toShortString()
    }
}

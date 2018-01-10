//
//  TargetValidator.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 09..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

enum TargetValidationResult {
    case success
    case failure(String)
}

struct TargetValidator {
    
    let ERROR_NAME_EMPTY = NSLocalizedString("TargetValidationErrorEmptyName", comment: "The name of the provided target is an empty string.")
    let ERROR_SCORES_EMPTY = NSLocalizedString("TargetValidationErrorEmptyScores", comment: "No scores were provided for the target.")
    
    func validate(target: Target) -> TargetValidationResult {
        let name = target.name.trimmingCharacters(in: .whitespaces)
        if name == "" {
            return .failure(ERROR_NAME_EMPTY)
        }
        if target.scores.count <= 0 {
            return .failure(ERROR_SCORES_EMPTY)
        }
        return .success
    }
}

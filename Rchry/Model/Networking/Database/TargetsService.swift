//
//  TargetsService.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 04..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import Firebase

struct TargetNames {
    
    static let PATH = "targets"
    static let NAME = "name"
    static let DISTANCE = "distance"
    static let SCORES = "scores"
    static let ICON = "icon"
}

protocol TargetService {
    
    func create(target: Target)
}

struct FirebaseTargetService {
    
    // This should be a database reference protocol really, but it takes a lot of work to create one, so this will suffice for now.
    // To mock it, just sublcass it and override the used methods. It's less safe, but it also takes less time...
    private var databaseReference: DatabaseReference
    
    // These could be protocols too
    private var jsonEncoder: JSONEncoder
    private var jsonDecoder: JSONDecoder
    
    // TODO: return observable
    func create(target: Target) {
        databaseReference.child(TargetNames.PATH).child(target.name).updateChildValues([
            TargetNames.DISTANCE: target.distance,
            TargetNames.SCORES: target.scores.reduce(into: [Float: Bool]()) { dict, pair in
                dict[pair] = true
            },
            TargetNames.ICON: target.icon
        ]) { error, snapshot in
            // TODO: call error or next (and complete) on observable that's returned?
        }
    }
}

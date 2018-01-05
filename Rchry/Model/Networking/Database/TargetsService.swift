//
//  TargetsService.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 04..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

struct TargetNames {
    
    static let PATH = "targets"
    static let NAME = "name"
    static let DISTANCE = "distance"
    static let SCORES = "scores"
    static let ICON = "icon"
}

protocol TargetService {
    
    func create(target: Target) -> Observable<Void>
}

struct FirebaseTargetService: TargetService {
    
    // This should be a database reference protocol really, but it takes a lot of work to create one, so this will suffice for now.
    // To mock it, just sublcass it and override the used methods. It's less safe, but it also takes less time...
    private var databaseReference: DatabaseReference
    
    // These could be protocols too
    private var jsonEncoder: JSONEncoder
    private var jsonDecoder: JSONDecoder
    
    init(databaseReference: DatabaseReference = Database.database().reference(), jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.databaseReference = databaseReference
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    // TODO: return observable
    func create(target: Target) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        guard let distanceString = target.distance.dashSeparatedString() else {
            subject.onError(DatabaseError.other)
            return subject.asObserver()
        }
        databaseReference.child(TargetNames.PATH).child(target.name + "-" + distanceString).updateChildValues([
            TargetNames.NAME: target.name,
            TargetNames.DISTANCE: target.distance,
            TargetNames.SCORES: target.scores,
            TargetNames.ICON: target.icon
        ]) { error, snapshot in
            if let error = error {
                subject.onError(DatabaseError.server)
            } else {
                subject.onCompleted()
            }
        }
        return subject.asObserver()
    }
}

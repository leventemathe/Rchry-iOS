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
    func doesTargetExist(withName name: String, andWithDistance distance: Float) -> Observable<Bool>
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
    
    static func createTargetKey(fromName name: String, andDistance distance: Float) -> String? {
        if let distanceString = distance.dashSeparatedString() {
            return name + "-" + distanceString
        }
        return nil
    }
    
    func create(target: Target) -> Observable<Void> {
        guard let pathName = FirebaseTargetService.createTargetKey(fromName: target.name, andDistance: target.distance) else {
            return Observable<Void>.error(DatabaseError.other)
        }
        return Observable<Void>.create { observer in
            self.databaseReference.child(TargetNames.PATH).child(pathName).updateChildValues([
                TargetNames.NAME: target.name,
                TargetNames.DISTANCE: target.distance,
                TargetNames.SCORES: target.scores,
                TargetNames.ICON: target.icon
            ]) { error, snapshot in
                if let error = error {
                    observer.onError(DatabaseError.server)
                } else {
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func doesTargetExist(withName name: String, andWithDistance distance: Float) -> Observable<Bool> {
        guard let pathName = FirebaseTargetService.createTargetKey(fromName: name, andDistance: distance) else {
            return Observable<Bool>.error(DatabaseError.other)
        }
        return Observable<Bool>.create { observer in
            self.databaseReference.child(TargetNames.PATH).child(pathName).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    observer.onNext(true)
                } else {
                    observer.onNext(false)
                }
                observer.onCompleted()
            }, withCancel: { error in
                observer.onError(DatabaseError.server)
            })
            return Disposables.create()
        }
    }
}












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
    static let PREFERRED_DISTANCE_UNIT = "preferred_distance_unit"
    static let SCORES = "scores"
    static let ICON = "icon"
    static let SHOTS = "shots"
    static let TIMESTAMP = "timestamp"
}

protocol TargetService {
    
    func create(target: Target) -> Observable<Target>
    func doesTargetExist(withName name: String, andWithDistance distance: Float) -> Observable<Bool>
    func observeTargets() -> Observable<[Target]>
}

class FirebaseTargetCoder {
    
    func encode(target: Target) -> [String: Any] {
        return [
            TargetNames.NAME: target.name,
            TargetNames.DISTANCE: target.distance,
            TargetNames.PREFERRED_DISTANCE_UNIT: target.preferredDistanceUnit.toString(),
            TargetNames.SCORES: target.scores,
            TargetNames.ICON: target.icon,
            TargetNames.SHOTS: target.shots,
            TargetNames.TIMESTAMP: target.timestamp
        ]
    }
    
    func decode(targetDicitonary: [String: Any]) -> Target? {
        guard let name = targetDicitonary[TargetNames.NAME] as? String else { return nil }
        guard let distance = targetDicitonary[TargetNames.DISTANCE] as? Float else { return nil }
        guard let preferredDistanceUnitString = targetDicitonary[TargetNames.PREFERRED_DISTANCE_UNIT] as? String,
              let preferredDistanceUnit = preferredDistanceUnitString.toDistanceUnit() else { return nil }
        var scores = targetDicitonary[TargetNames.SCORES] as? [Float]
        if scores == nil {
            scores = [Float]()
        }
        guard let icon = targetDicitonary[TargetNames.ICON] as? String else { return nil }
        guard let shots = targetDicitonary[TargetNames.SHOTS] as? Int else { return nil }
        guard let timestamp = targetDicitonary[TargetNames.TIMESTAMP] as? Double else { return nil }
        return Target(name: name, distance: distance, preferredDistanceUnit: preferredDistanceUnit, scores: scores!, icon: icon, timestamp: timestamp, shots: shots)
    }
    
    func decode(targetsDicitonary: [String: Any]) -> [Target] {
        var targets = [Target]()
        targetsDicitonary.forEach { _, targetDictionary in
            if let targetDictionary = targetDictionary as? [String: Any], let target = decode(targetDicitonary: targetDictionary) {
                targets.append(target)
            }
        }
        return targets
    }
    
    func createTargetKey(_ target: Target) -> String? {
        return createTargetKey(fromName: target.name, andDistance: target.distance)
    }
    
    func createTargetKey(fromName name: String, andDistance distance: Float) -> String? {
        if let distanceString = distance.dashSeparatedString() {
            return name + "-" + distanceString
        }
        return nil
    }
}

class FirebaseTargetService: TargetService {
    
    // This should be a database reference protocol really, but it takes a lot of work to create one, so this will suffice for now.
    // To mock it, just sublcass it and override the used methods. It's less safe, but it also takes less time...
    private var databaseReference: DatabaseReference
    private var targetCoder: FirebaseTargetCoder
    private var authService: AuthService
    
    init(databaseReference: DatabaseReference = Database.database().reference(),
         firebaseTargetCoder: FirebaseTargetCoder = FirebaseTargetCoder(),
         authService: AuthService = FirebaseAuthService()) {
        self.databaseReference = databaseReference
        self.targetCoder = firebaseTargetCoder
        self.authService = authService
    }
    
    func create(target: Target) -> Observable<Target> {
        guard let uid = authService.userID else {
            return Observable<Target>.error(DatabaseError.userNotLoggedIn)
        }
        guard let pathName = targetCoder.createTargetKey(fromName: target.name, andDistance: target.distance) else {
            return Observable.error(DatabaseError.other)
        }
        return Observable.create { [unowned self] observer in
            self.databaseReference.child(uid).child(TargetNames.PATH).child(pathName).updateChildValues(self.targetCoder.encode(target: target)) { error, snapshot in
                if let _ = error {
                    observer.onError(DatabaseError.server)
                } else {
                    observer.onNext(target)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func doesTargetExist(withName name: String, andWithDistance distance: Float) -> Observable<Bool> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        guard let pathName = targetCoder.createTargetKey(fromName: name, andDistance: distance) else {
            return Observable<Bool>.error(DatabaseError.other)
        }
        return Observable.create { [weak self] observer in
            self?.databaseReference.child(uid).child(TargetNames.PATH).child(pathName).observeSingleEvent(of: .value, with: { snapshot in
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
    
    func observeTargets() -> Observable<[Target]> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        return Observable.create { [unowned self] observer in
            let handle = self.databaseReference.child(uid).child(TargetNames.PATH).observe(.value, with: { snapshot in
                if let value = snapshot.value, let targetsDict = value as? [String: Any] {
                    let targets = self.targetCoder.decode(targetsDicitonary: targetsDict)
                    observer.onNext(targets)
                }
            }, withCancel: { error in
                observer.onError(DatabaseError.server)
            })
            return Disposables.create {
                self.databaseReference.removeObserver(withHandle: handle)
            }
        }
    }
}












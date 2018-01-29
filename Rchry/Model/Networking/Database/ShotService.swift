//
//  ShotService.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 26..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

struct ShotNames {
    
    static let MY_SCORE = "my_score"
}

protocol ShotService {
    
    func add(shot: Shot, forSession session: Session) -> Observable<Shot>
}

struct FirebaseShotCoder {
    
    func encode(shot: Shot) -> [String: Any] {
        return shot.scores.reduce(into: [String: Any](), { result, scoreByUser in
            result[scoreByUser.0] = scoreByUser.1
        })
    }
    
    func decode(dictionary: [String: Any]) -> Shot? {
        guard let indexString = dictionary.keys.first, let index = Int(indexString) else {
            return nil
        }
        guard let scoresByUserDict = dictionary.values.first as? [String: Float] else {
            return nil
        }
        let scoresByUser = scoresByUserDict.reduce(into: [(String, Float?)](), { result, scoreByUser in
            result.append((scoreByUser.key, scoreByUser.value))
        })
        return Shot(index: index, scores: scoresByUser, active: false)
    }
    
    func decode(dictionary: [String: Any]) -> [Shot] {
        var shots = [Shot]()
        for (_, value) in dictionary {
            if let shotDict = value as? [String: Any], let shot: Shot = decode(dictionary: shotDict) {
                shots.append(shot)
            }
        }
        return shots
    }
}

class FirebaseShotService: ShotService {
    
    private var databaseReference: DatabaseReference
    private var shotCoder: FirebaseShotCoder
    private var sessionCoder: FirebaseSessionCoder
    private var authService: AuthService
    
    init(databaseReference: DatabaseReference = DatabaseReference(),
         shotCoder: FirebaseShotCoder = FirebaseShotCoder(),
         sessionCoder: FirebaseSessionCoder = FirebaseSessionCoder(),
         authService: AuthService = FirebaseAuthService()) {
        self.databaseReference = databaseReference
        self.shotCoder = shotCoder
        self.sessionCoder = sessionCoder
        self.authService = authService
    }
    
    func add(shot: Shot, forSession session: Session) -> Observable<Shot> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        return Observable.create { [unowned self] observer in
            let update = self.shotCoder.encode(shot: shot)
            self.databaseReference.child(uid).child(SessionNames.PATH).child(self.sessionCoder.createSessionKey(fromSession: session)).child(String(shot.index)).updateChildValues(update, withCompletionBlock: { error, ref in
                if let _ = error {
                    observer.onError(DatabaseError.server)
                } else {
                    observer.onNext(shot)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
}

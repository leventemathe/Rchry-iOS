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
    
    static let PATH = "shots"
    static let MY_SCORE = "my_score"
}

protocol ShotService {
    
    func update(score: Float, byUser user: String, forIndex index: Int, inSession session: Session) -> Observable<(Float, String, Int)>
}

class FirebaseShotService: ShotService {
    
    private var databaseReference: DatabaseReference
    private var authService: AuthService
    private var sessionCoder: FirebaseSessionCoder
    
    init(databaseReference: DatabaseReference = Database.database().reference(),
         authService: AuthService = FirebaseAuthService(),
         sessionCoder: FirebaseSessionCoder = FirebaseSessionCoder()) {
        self.databaseReference = databaseReference
        self.authService = authService
        self.sessionCoder = sessionCoder
    }

    /*
    func update(score: Float, byUser user: String, forIndex index: Int, inSession session: Session) -> Observable<(Float, String, Int)> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        let sessionPath = sessionCoder.createSessionKey(fromSession: session)
        return Observable.create { [unowned self] observer in
            self.databaseReference.child(uid).child(SessionNames.PATH).child(sessionPath).child(ShotNames.PATH).child(String(index)).child(user).setValue(score, withCompletionBlock: { error, _ in
                if error != nil {
                    observer.onError(DatabaseError.server)
                } else {
                    observer.onNext((score, user, index))
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
 */
    
    
    func update(score: Float, byUser user: String, forIndex index: Int, inSession session: Session) -> Observable<(Float, String, Int)> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        let sessionPath = sessionCoder.createSessionKey(fromSession: session)
        return Observable.create { [unowned self] observer in
            self.databaseReference.child(uid).child(SessionNames.PATH).child(sessionPath).child(ShotNames.PATH).child(user).child(String(index)).setValue(score, withCompletionBlock: { error, _ in
                if error != nil {
                    observer.onError(DatabaseError.server)
                } else {
                    observer.onNext((score, user, index))
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
}

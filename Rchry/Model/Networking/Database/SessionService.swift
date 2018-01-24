//
//  SessionService.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 23..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

struct SessionNames {
    static let PATH = "sessions"
    static let MY_SCORES = "my_scores"
    // Guests are saved here too for easy retrieval
    static let SAVED_GUESTS = "guests"
    
    static let TIMESTAMP = "timestamp"
    static let NAME = "name"
}

protocol SessionService {
    
    func create(session: Session) -> Observable<Session>
}

struct FirebaseSessionCoder {
    
    func encode(session: Session, withTimestamp timestamp: Double, underTarget target: String) -> [String: Any] {
        let sessionKey = "\(session.name)-\(Int(timestamp))"
        
        let sessionDataDict: [String: Any] = [
            "\(SessionNames.PATH)/\(sessionKey)/name": session.name,
            "\(SessionNames.PATH)/\(sessionKey)/timestamp": timestamp,
            "\(SessionNames.PATH)/\(sessionKey)/target": target
        ]
        
        // TODO: remove this, after some scores have been written
        let mySessionScoresDict = [
            "\(SessionNames.PATH)/\(sessionKey)/\(SessionNames.MY_SCORES)/": timestamp as Any
        ]
        
        // TODO: remove this, after some scores have been written
        let guestSessionScoresDict = session.guests.reduce(into: [String: Any](), { dict, guest in
            dict["\(SessionNames.PATH)/\(sessionKey)/\(guest)"] = timestamp as Any
        })
        
        let savedGuestsDict = session.guests.reduce(into: [String: Any](), { dict, guest in
            dict["\(SessionNames.SAVED_GUESTS)/\(guest)"] = timestamp as Any
        })
        
        return sessionDataDict
            .merging(mySessionScoresDict, uniquingKeysWith: { one, two in one })
            .merging(guestSessionScoresDict, uniquingKeysWith: { one, two in  one })
            .merging(savedGuestsDict, uniquingKeysWith: { one, two in  one })
    }
}

class FirebaseSessionService: SessionService {
    
    private let databaseRef: DatabaseReference
    private let authService: AuthService
    private let firebaseSessionCoder: FirebaseSessionCoder
    private let firebaseTargetCoder: FirebaseTargetCoder
    private let dateProvider: DateProvider
    
    init(databaseRef: DatabaseReference = Database.database().reference(),
         authService: AuthService = FirebaseAuthService(),
         firebaseSessionCoder: FirebaseSessionCoder = FirebaseSessionCoder(),
         firebaseTargetCoder: FirebaseTargetCoder = FirebaseTargetCoder(),
         dateProvider: DateProvider = BasicDateProvider()) {
        self.databaseRef = databaseRef
        self.authService = authService
        self.firebaseSessionCoder = firebaseSessionCoder
        self.firebaseTargetCoder = firebaseTargetCoder
        self.dateProvider = dateProvider
    }
    
    func create(session: Session) -> Observable<Session> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        return Observable.create { [unowned self] observer in
            if let underTarget = self.firebaseTargetCoder.createTargetKey(session.ownerTarget) {
                let updateDict = self.firebaseSessionCoder.encode(session: session, withTimestamp: self.dateProvider.currentTimestamp, underTarget: underTarget)
                self.databaseRef.child(uid).updateChildValues(updateDict, withCompletionBlock: { error, ref in
                    if let _ = error {
                        observer.onError(DatabaseError.server)
                    } else {
                        observer.onNext(session)
                        observer.onCompleted()
                    }
                })
            } else {
                observer.onError(DatabaseError.other)
            }
            return Disposables.create()
        }
    }
}

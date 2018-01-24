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
    static let MY_PATH = "my_sessions"
    static let GUEST_PATH = "guest_sessions"
    // Guests are saved here too for easy retrieval
    static let SAVED_GUESTS = "guests"
}

protocol SessionService {
    
    func create(session: Session) -> Observable<Session>
}

struct FirebaseSessionCoder {
    
    func encode(session: Session, withTimestamp timestamp: Double, underTarget target: String) -> [String: Any] {
        let sessionKey = "\(session.name)-\(Int(timestamp))"
        let guestDictWithTimestamp = session.guests.reduce(into: [String: [String: Double]](), { dict, guest in dict[guest] = [sessionKey: timestamp] })
        return [
            "\(TargetNames.PATH)/\(target)/\(SessionNames.MY_PATH)/\(sessionKey)": timestamp,
            "\(TargetNames.PATH)/\(target)/\(SessionNames.GUEST_PATH)": guestDictWithTimestamp,
            "\(SessionNames.SAVED_GUESTS)": guestDictWithTimestamp
        ]
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

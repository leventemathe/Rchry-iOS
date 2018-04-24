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
    static let TIMESTAMP = "timestamp"
    static let NAME = "name"
    static let TARGET = "target"
    static let SHOTS = "shots"
    static let SAVED_GUESTS = "guests"
}

protocol SessionService {
    
    func create(session: Session) -> Observable<Session>
    func observeGuests() -> Observable<[String]>
    func getGuests() -> Observable<[String]>
    func getSessions(underTarget target: Target) -> Observable<[Session]>
    func delete(session: Session) -> Observable<Void>
}

struct FirebaseSessionCoder {
    
    func encode(session: Session, underTarget target: String) -> [String: Any] {
        
        let sessionKey = createSessionKey(fromSession: session)
        let timestamp = session.timestamp
        
        let sessionDataDict: [String: Any] = [
            "\(SessionNames.PATH)/\(sessionKey)/\(SessionNames.NAME)": session.name,
            "\(SessionNames.PATH)/\(sessionKey)/\(SessionNames.TIMESTAMP)": timestamp,
            "\(SessionNames.PATH)/\(sessionKey)/\(SessionNames.TARGET)": target
        ]
        
        let savedGuestsDict = session.shotsByUser
            .filter { $0.0 != ShotNames.MY_SCORE }
            .map { $0.0 }
            .reduce(into: [String: Any](), { dict, guest in
            dict["\(SessionNames.SAVED_GUESTS)/\(guest)"] = timestamp as Any
        })
        
        return sessionDataDict
            .merging(savedGuestsDict, uniquingKeysWith: { one, two in  one })
    }
    
    func decode(_ dict: [String: Any], underTarget target: Target) -> [Session]? {
        guard let dict = dict as? [String: [String: Any]] else {
            return nil
        }
        var sessions = [Session]()
        for (_, sessionDict) in dict {
            if let name = sessionDict[SessionNames.NAME] as? String, let timestamp = sessionDict[SessionNames.TIMESTAMP] as? Double, let shotsByUserDict = sessionDict[ShotNames.PATH] as? [String: Any] {
                if let shotsByUser = shotsByUserDict as? [String: [Float]] {
                    sessions.append(Session(ownerTarget: target, name: name, timestamp: timestamp, shotsByUser: shotsByUser))
                }
            }
        }
        return sessions.count > 0 ? sessions : nil
    }
    
    func createSessionKey(fromSession session: Session) -> String {
        if session.name != "" {
            return "\(session.name)-\(Int(session.timestamp))"
        }
        return String(Int(session.timestamp))
    }
}

class FirebaseSessionService: SessionService {
    
    private let databaseRef: DatabaseReference
    private let authService: AuthService
    private let firebaseSessionCoder: FirebaseSessionCoder
    private let firebaseTargetCoder: FirebaseTargetCoder
    
    init(databaseRef: DatabaseReference = Database.database().reference(),
         authService: AuthService = FirebaseAuthService(),
         firebaseSessionCoder: FirebaseSessionCoder = FirebaseSessionCoder(),
         firebaseTargetCoder: FirebaseTargetCoder = FirebaseTargetCoder()) {
        self.databaseRef = databaseRef
        self.authService = authService
        self.firebaseSessionCoder = firebaseSessionCoder
        self.firebaseTargetCoder = firebaseTargetCoder
    }
    
    func create(session: Session) -> Observable<Session> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        return Observable.create { [unowned self] observer in
            if let underTarget = self.firebaseTargetCoder.createTargetKey(session.ownerTarget) {
                let updateDict = self.firebaseSessionCoder.encode(session: session, underTarget: underTarget)
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
    
    func observeGuests() -> Observable<[String]> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        return Observable.create { [unowned self] observer in
            let handle = self.databaseRef.child(uid).child(SessionNames.SAVED_GUESTS).observe(.value, with: { snapshot in
                if let guestsDict = snapshot.value as? [String: Any] {
                    let guests = guestsDict.keys.map { $0 }
                    observer.onNext(guests)
                }
            }, withCancel: { error in
                // TODO: Instead of terminating stream, pass the error in onNext
                // TODO: Similarly in other services too
                observer.onError(DatabaseError.server)
            })
            return Disposables.create { self.databaseRef.removeObserver(withHandle: handle) }
        }
    }
    
    func getGuests() -> Observable<[String]> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        return Observable.create { [unowned self] observer in
            self.databaseRef.child(uid).child(SessionNames.SAVED_GUESTS).observeSingleEvent(of: .value, with: { snapshot in
                if let guestsDict = snapshot.value as? [String: Any] {
                    let guests = guestsDict.keys.map { $0 }
                    observer.onNext(guests)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    func getSessions(underTarget target: Target) -> Observable<[Session]> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        return Observable.create { [unowned self] observer in
            let targetName: String = self.firebaseTargetCoder.createTargetKey(target)!
            self.databaseRef.child(uid).child(SessionNames.PATH).queryOrdered(byChild: SessionNames.TARGET).queryEqual(toValue: targetName).observeSingleEvent(of: .value, with: { snapshot in
                if let dict = snapshot.value as? [String: Any] {
                    if var sessions = self.firebaseSessionCoder.decode(dict, underTarget: target) {
                        sessions.sort(by: { $0.timestamp < $1.timestamp })
                        observer.onNext(sessions)
                    }
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
    
    // Not checking for errors, because local caching is on
    func delete(session: Session) -> Observable<Void> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        return Observable.create { [unowned self] observer in
            let key = self.firebaseSessionCoder.createSessionKey(fromSession: session)
            self.databaseRef.child(uid).child(SessionNames.PATH).child(key).setValue(nil)
            observer.onCompleted()
            return Disposables.create()
        }
    }
}

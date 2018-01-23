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
}

protocol SessionService {
    
    func create(session: Session) -> Observable<Session>
}

class FirebaseSessionSevice: SessionService {
    
    private let databaseRef: DatabaseReference
    private let authService: AuthService
    
    init(databaseRef: DatabaseReference = Database.database().reference(), authService: AuthService = FirebaseAuthService()) {
        self.databaseRef = databaseRef
        self.authService = authService
    }
    
    func create(session: Session) -> Observable<Session> {
        guard let uid = authService.userID else {
            return Observable.error(DatabaseError.userNotLoggedIn)
        }
        let myObservable = self.createMySession(session.name)
        let guestsObservable = self.createGuestSessions(session.guests)
        return Observable.combineLatest(myObservable, guestsObservable, resultSelector: { ($0, $1) })
            .map { Session(name: $0.0, guests: $0.1) }
    }
    
    private func createMySession(_ name: String) -> Observable<String> {
        return Observable.just("")
        // TODO:
    }
    
    private func createGuestSessions(_ guests: [String]) -> Observable<[String]> {
        return Observable.just([String]())
        // TODO:
    }
}

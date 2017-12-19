//
//  FirebaseLoginService.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseAuth {
    
    func signIn(with credential: AuthCredential, completion: @escaping AuthResultCallback)
    func signOut(_ completion: @escaping (Error?) -> ())
    func deleteCurrentUser(_ completion: @escaping (Error?) -> ())
    func getUser() -> User?
}

fileprivate struct BasicFirebaseAuth: FirebaseAuth {
    
    func signIn(with credential: AuthCredential, completion: @escaping AuthResultCallback) {
        Auth.auth().signIn(with: credential, completion: completion)
    }
    
    func signOut(_ completion: @escaping (Error?) -> ()) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            completion(AuthError.other)
        }
    }
    
    func deleteCurrentUser(_ completion: @escaping (Error?) -> ()) {
        Auth.auth().currentUser?.delete { error in
            completion(AuthError.other)
        }
    }
    
    func getUser() -> User? {
        return Auth.auth().currentUser
    }
}

struct FirebaseAuthService: AuthService {
    
    var firebaseAuth: FirebaseAuth
    
    init(firebaseAuth: FirebaseAuth = BasicFirebaseAuth()) {
        self.firebaseAuth = firebaseAuth
    }
    
    func login(_ socialProvider: SocialProvider, withToken token: String, withCompletion completion: @escaping (AuthError?)->()) {
        switch socialProvider {
        case .facebook:
            loginWithFacebook(token, withCompletion: completion)
        }
    }
    
    private func loginWithFacebook(_ token: String, withCompletion completion: @escaping (AuthError?)->()) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        firebaseAuth.signIn(with: credential) { (user, error) in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                switch errorCode {
                case .credentialAlreadyInUse:
                    completion(.credentialTaken)
                case .invalidCredential:
                    completion(.invalidCredential)
                default:
                    completion(.other)
                }
                return
            }
            completion(nil)
        }
        
    }
    
    func logout(_ completion: @escaping (AuthError?)->()) {
        firebaseAuth.signOut { error in
            if let _ = error {
                completion(.other)
            } else {
                completion(nil)
            }
        }
    }
    
    func deleteUser(_ completion: @escaping (AuthError?)->()) {
        firebaseAuth.deleteCurrentUser { error in
            if let _ = error {
                completion(.other)
            } else {
                completion(nil)
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        if let _ = firebaseAuth.getUser() {
            return true
        }
        return false
    }
}

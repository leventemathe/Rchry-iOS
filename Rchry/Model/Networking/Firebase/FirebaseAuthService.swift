//
//  FirebaseLoginService.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseAuthService: AuthService {
    
    private static var _instance = FirebaseAuthService()
    
    static var instance: FirebaseAuthService {
        return _instance
    }
    
    private init() {}
    
    func login(_ socialProvider: SocialProvider, withToken token: String, withCompletion completion: @escaping (AuthError?)->()) {
        switch socialProvider {
        case .facebook:
            loginWithFacebook(token, withCompletion: completion)
        }
    }
    
    private func loginWithFacebook(_ token: String, withCompletion completion: @escaping (AuthError?)->()) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: credential) { (user, error) in
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
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            completion(.other)
        }
    }
    
    func deleteUser(_ completion: @escaping (AuthError?)->()) {
        Auth.auth().currentUser?.delete { error in
            completion(.other)
        }
    }
}

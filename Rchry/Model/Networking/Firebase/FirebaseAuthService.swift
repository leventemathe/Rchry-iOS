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
            FacebookAuthProvider.credential(withAccessToken: token)
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
        
    }
}

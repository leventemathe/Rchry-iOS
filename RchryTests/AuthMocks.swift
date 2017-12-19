//
//  AuthMocks.swift
//  RchryTests
//
//  Created by Máthé Levente on 2017. 12. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
@testable import Rchry
import FBSDKLoginKit
import Firebase

class FacebookLoginManagerMock: FacebookLoginManager {
    
    var result: FBSDKLoginManagerLoginResult?
    var error: Error?
    
    func logIn(withReadPermissions permissions: [String], from vc: UIViewController!, handler: FBSDKLoginManagerRequestTokenHandler!) {
        if let error = error {
            handler(nil, error)
        } else if let result = result {
            handler(result, nil)
        } else {
            handler(nil, nil)
        }
    }
    
    func logout() {
        
    }
}

class FirebaseAuthMock: FirebaseAuth {

    var error: Error?
    
    func signIn(with credential: AuthCredential, completion: @escaping AuthResultCallback) {
        if let error = error {
            completion(nil, error)
        } else {
            completion(nil, nil)
        }
    }
    
    func signOut(_ completion: @escaping (Error?) -> ()) {
        if let error = error {
            completion(error)
        } else {
            completion(nil)
        }
    }
    
    func deleteCurrentUser(_ completion: @escaping (Error?) -> ()) {
        if let error = error {
            completion(error)
        } else {
            completion(nil)
        }
    }
    
    func getUser() -> User? {
        return nil
    }
}

class FacebookAuthServiceMock: SocialAuthService {
    
    var error: AuthError?
    var token = ""
    
    func login(_ completion: @escaping (AuthError?, _ token: String?)->()) {
        if let error = error {
            completion(error, nil)
            return
        }
        completion(nil, token)
    }
    
    func logout(_ completion: @escaping (AuthError?)->()) {
        if let error = error {
            completion(error)
            return
        }
        completion(nil)
    }
}

class AuthServiceMock: AuthService {
    
    var error: AuthError?
    
    func login(_ socialProvider: SocialProvider, withToken token: String, withCompletion completion: @escaping (AuthError?)->()) {
        if let error = error {
            completion(error)
            return
        }
        completion(nil)
    }
    
    func logout(_ completion: @escaping (AuthError?)->()) {
        if let error = error {
            completion(error)
            return
        }
        completion(nil)
    }
    
    func deleteUser(_ completion: @escaping (AuthError?)->()) {
        if let error = error {
            completion(error)
            return
        }
        completion(nil)
    }
    
    func isLoggedIn() -> Bool {
        return true
    }
}

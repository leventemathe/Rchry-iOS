//
//  AuthMocks.swift
//  RchryTests
//
//  Created by Máthé Levente on 2017. 12. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
@testable import Rchry

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
}

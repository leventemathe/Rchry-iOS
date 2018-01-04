//
//  AuthService.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

enum AuthError: Error {
    case cancelled
    case network
    case permissionDenied
    case credentialTaken
    case invalidCredential
    case other
}

enum SocialProvider {
    case facebook
}

protocol AuthService {
    
    func login(_ socialProvider: SocialProvider, withToken token: String, withCompletion completion: @escaping (AuthError?)->())
    func logout(_ completion: @escaping (AuthError?)->())
    func deleteUser(_ completion: @escaping (AuthError?)->())
    func isLoggedIn() -> Bool
}

//
//  FacebookService.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import FBSDKLoginKit

protocol FacebookLoginManager {

    func logIn(withReadPermissions permissions: [String], from vc: UIViewController!, handler: FBSDKLoginManagerRequestTokenHandler!)
    func logout()
}

fileprivate struct BasicFacebookLoginManager: FacebookLoginManager {
    
    private let manager = FBSDKLoginManager()
    
    func logIn(withReadPermissions permissions: [String], from vc: UIViewController!, handler: FBSDKLoginManagerRequestTokenHandler!) {
        manager.logIn(withReadPermissions: permissions, from: vc, handler: handler)
    }
    
    func logout() {
        FBSDKLoginManager().logOut()
    }
}

struct FacebookAuthService: SocialAuthService {
    
    private var loginManager: FacebookLoginManager
    
    init(_ loginManager: FacebookLoginManager = BasicFacebookLoginManager()) {
        self.loginManager = loginManager
    }
    
    func login(_ completion: @escaping (AuthError?, _ token: String?)->()) {
        loginManager.logIn(withReadPermissions: ["public_profile"], from: nil, handler: { (result, error) in
            if error != nil {
                completion(.other, nil)
                return
            } else if let result = result {
                self.handleResult(result, withCompletion: completion)
                return
            }
            completion(.other, nil)
        })
    }
        
    private func handleResult(_ result: FBSDKLoginManagerLoginResult, withCompletion completion: @escaping (AuthError?, _ token: String?)->()) {
        if result.declinedPermissions != nil && result.declinedPermissions.count > 0 {
            completion(.permissionDenied, nil)
        } else if result.isCancelled {
            completion(.cancelled, nil)
        } else if result.token != nil {
            completion(nil, result.token.tokenString)
        } else {
            completion(.other, nil)
        }
        return
    }
    
    func logout(_ completion: @escaping (AuthError?)->()) {
        loginManager.logout()
        completion(nil)
    }
}


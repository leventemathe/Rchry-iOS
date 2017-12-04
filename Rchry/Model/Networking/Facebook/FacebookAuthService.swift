//
//  FacebookService.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FacebookAuthService: SocialAuthService {
    
    private static var _instance = FacebookAuthService()
    
    static var instance: FacebookAuthService {
        return _instance
    }
    
    private init() {}
    
    func login(_ completion: @escaping (AuthError?, _ token: String?)->()) {
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile"], from: nil, handler: { (result, error) in
            if error != nil {
                completion(.other, nil)
                return
            } else if let result = result {
                if result.declinedPermissions != nil {
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
            completion(.other, nil)
        })
    }
    
    func logout(_ completion: @escaping (AuthError?)->()) {
        FBSDKLoginManager().logOut()
        completion(nil)
    }
}


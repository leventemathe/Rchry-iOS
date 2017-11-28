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
    
    func login(_ completion: @escaping (AuthError?)->()) {
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile"], from: nil, handler: { (result, error) in
            if let error = error {
                print(error)
                completion(.other)
                return
            } else if let result = result {
                print(result)
                completion(nil)
                return
            }
            print("other error while facebook login")
            completion(.other)
        })
    }
    
    func logout(_ completion: @escaping (AuthError?)->()) {
        // TODO: errors?!?
        FBSDKLoginManager().logOut()
    }
}


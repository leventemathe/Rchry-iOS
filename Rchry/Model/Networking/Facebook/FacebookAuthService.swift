//
//  FacebookService.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FacebookAuthService: NSObject, SocialAuthService {
    
    private static var _instance = FacebookAuthService()
    
    static var instance: FacebookAuthService {
        return _instance
    }
    
    func logout() {
        FBSDKLoginManager().logOut()
    }
}

extension FacebookAuthService: FBSDKLoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            
            return
        }
        
        let token = FBSDKAccessToken.current().tokenString
    }
}

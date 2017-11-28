//
//  LoginVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct LoginVM {
    
    var facebookAuthService: SocialAuthService
    var authService: AuthService
    
    func login(_ completion: @escaping (AuthError?)->()) {
        facebookAuthService.login { error in
            if let error = error {
                completion(error)
                return
            }
            print("yay logged in with facebook")
            completion(nil)
            // TODO: login with firebase too
        }
    }
}

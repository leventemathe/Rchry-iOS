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
    
    func loginWithFacebook(_ completion: @escaping (AuthError?)->()) {
        login(.facebook, withCompletion: completion)
    }
    
    private func login(_ social: SocialProvider, withCompletion completion: @escaping (AuthError?)->()) {
        var service: SocialAuthService!
        switch social {
        case .facebook:
            service = facebookAuthService
        }
        service.login { (error, token) in
            if let error = error {
                completion(error)
                return
            }
            if let token = token {
                self.loginToAccount(withSocialProvider: social, withToken: token, withCompletion: completion)
            }
            completion(.invalidCredential)
        }
    }
    
    private func loginToAccount(withSocialProvider social: SocialProvider, withToken token: String, withCompletion completion: @escaping (AuthError?)->()) {
        self.authService.login(social, withToken: token, withCompletion: { error in
            if let error = error {
                self.facebookAuthService.logout { error in
                    completion(error)
                }
                completion(error)
                return
            }
            completion(nil)
        })
        return
    }
}

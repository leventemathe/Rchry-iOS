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
    var authErrorHandler: AuthErrorHandler
    
    func loginWithFacebook(_ completion: @escaping (_ errorMessage: String?)->()) {
        login(.facebook, withCompletion: completion)
    }
    
    private func login(_ social: SocialProvider, withCompletion completion: @escaping (String?)->()) {
        var socialService: SocialAuthService!
        switch social {
        case .facebook:
            socialService = facebookAuthService
        }
        socialService.login { (error, token) in
            if let error = error {
                self.authErrorHandler.handle(error: error, withCompletion: completion)
                return
            }
            if let token = token {
                self.loginToAccount(withSocialProvider: social, withToken: token, withCompletion: completion)
                return
            }
            completion(self.authErrorHandler.ERROR_CREDENTIAL_INVALID)
        }
    }
    
    private func loginToAccount(withSocialProvider social: SocialProvider, withToken token: String, withCompletion completion: @escaping (String?)->()) {
        self.authService.login(social, withToken: token, withCompletion: { error in
            if let error = error {
                self.facebookAuthService.logout { error in
                    if let error = error {
                        self.authErrorHandler.handle(error: error, withCompletion: completion)
                    }
                    return
                }
                self.authErrorHandler.handle(error: error, withCompletion: completion)
                return
            }
            completion(nil)
        })
    }
}

//
//  ProfileVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct ProfileVM {
    
    var facebookAuthService: SocialAuthService
    var authService: AuthService
    var authErrorHandler: AuthErrorToMessageMapper
    
    func logout(_ completion: @escaping (_ errorMessage: String?)->()) {
        authService.logout { error in
            if let error = error {
                self.authErrorHandler.map(error: error, withCompletion: completion)
                return
            }
            self.facebookAuthService.logout { error in
                if let error = error {
                    self.authErrorHandler.map(error: error, withCompletion: completion)
                    return
                }
                completion(nil)
            }
        }
    }
}

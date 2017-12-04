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
    
    func logout(_ completion: @escaping (AuthError?)->()) {
        authService.logout { error in
            if let error = error {
                completion(error)
                return
            }
            self.facebookAuthService.logout { error in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
    }
}

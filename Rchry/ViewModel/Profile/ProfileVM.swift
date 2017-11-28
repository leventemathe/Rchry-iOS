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
    
    func logout() {
        authService.logout { error in
            print("logged out from firebase")
            self.facebookAuthService.logout { error in
                print("logged out ffrom facebook")
            }
        }
    }
}

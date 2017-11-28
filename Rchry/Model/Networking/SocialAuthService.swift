//
//  AuthService.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

protocol SocialAuthService {
    
    func login(_ completion: @escaping (AuthError?)->())
    func logout(_ completion: @escaping (AuthError?)->())
}

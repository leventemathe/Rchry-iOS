//
//  AuthService.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

enum SocialProvider {
    case facebook
}

protocol AuthService {
    
    func login(_ socialProvider: SocialProvider, withToken token: String)
    func logout()
    func deleteUser()
}

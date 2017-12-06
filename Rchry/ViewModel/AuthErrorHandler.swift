//
//  AuthErrorHandler.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 12. 06..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

protocol AuthErrorHandler {

    var ERROR_CANCELLED: String {
        get
    }
    var ERROR_CREDENTIAL_TAKEN:String {
        get
    }
    var ERROR_CREDENTIAL_INVALID: String {
        get
    }
    var ERROR_NETWORK: String {
        get
    }
    var ERROR_OTHER: String {
        get
    }
    
    func handle(error: AuthError, withCompletion completion: @escaping (String?)->())
}

struct BasicAuthErrorHandler: AuthErrorHandler {
    
    var ERROR_CANCELLED: String {
        return NSLocalizedString("AuthErrorCancelled", comment: "An error message that is presented when the user cancels the social login, e.g. Facebook")
    }
    var ERROR_CREDENTIAL_TAKEN:String {
        return NSLocalizedString("AuthErrorCredentialTaken", comment: "An error message that is presented when the social credentials are taken")
    }
    var ERROR_CREDENTIAL_INVALID: String {
        return NSLocalizedString("AuthErrorCredentialInvalid", comment: "An error message that indicates the social credential is invalid")
    }
    var ERROR_NETWORK: String {
        return NSLocalizedString("AuthErrorNetwork", comment: "An error message for network errors, like no internet")
    }
    var ERROR_OTHER: String {
        return NSLocalizedString("AuthErrorOther", comment: "An error message for an unknown error")
    }
    
    func handle(error: AuthError, withCompletion completion: @escaping (String?)->()) {
        switch error {
        case .cancelled:
            completion(self.ERROR_CANCELLED)
        case .credentialTaken:
            completion(self.ERROR_CREDENTIAL_TAKEN)
        case .invalidCredential:
            completion(self.ERROR_CREDENTIAL_INVALID)
        case .network:
            completion(self.ERROR_NETWORK)
        case .other, .permissionDenied:
            completion(self.ERROR_OTHER)
        }
    }
}

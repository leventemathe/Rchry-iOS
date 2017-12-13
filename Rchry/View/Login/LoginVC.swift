//
//  LoginVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 23..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import LMViews
import FBSDKLoginKit

class LoginVC: UIViewController {
    
    let ERROR_TITLE = NSLocalizedString("LoginErrorTitle", comment: "The title for the login error")
    
    private var loginVM = LoginVM(facebookAuthService: FacebookAuthService(), authService: FirebaseAuthService(), authErrorHandler: BasicAuthErrorHandler())
    
    @IBAction func facebookLoginBtnTouched(_ sender: LMButton) {
        loginVM.loginWithFacebook { errorMessage in
            if let errorMessage = errorMessage {
                MessageAlertModalVC.present(withTitle: self.ERROR_TITLE, withMessage: errorMessage, fromVC: self)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

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

class LoginVC: UIViewController, StoryboardInstantiable {
    
    private var loginVM = LoginVM(facebookAuthService: FacebookAuthService(), authService: FirebaseAuthService(), authErrorHandler: BasicAuthErrorToMessageMapper())
    
    @IBAction func facebookLoginBtnTouched(_ sender: LMButton) {
        loginVM.loginWithFacebook { errorMessage in
            if let errorMessage = errorMessage {
                MessageAlertModalVC.present(withTitle: CommonMessages.ERROR_TITLE, withMessage: errorMessage, fromVC: self)
            } else {
                self.presentTargetsVC()
            }
        }
    }
    
    private func presentTargetsVC() {
        if let parent = parent as? MainVC {
            parent.setTargetsNavigationVC()
        } else {
            fatalError("The parent of login vc should be main vc.")
        }
    }
}

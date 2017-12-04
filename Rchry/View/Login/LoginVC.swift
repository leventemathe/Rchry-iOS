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
    
    private var loginVM = LoginVM(facebookAuthService: FacebookAuthService.instance, authService: FirebaseAuthService.instance)
    
    @IBAction func facebookLoginBtnTouched(_ sender: LMButton) {
        loginVM.loginWithFacebook { error in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

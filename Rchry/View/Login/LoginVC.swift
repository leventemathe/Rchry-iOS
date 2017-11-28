//
//  LoginVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 23..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginVC: UIViewController {
    
    private var loginVM = LoginVM()
    
    @IBOutlet weak var facbookLoginBtn: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facbookLoginBtn.delegate = loginVM.facebookAuthService as! FBSDKLoginButtonDelegate
        facbookLoginBtn.readPermissions = ["public_profile"]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

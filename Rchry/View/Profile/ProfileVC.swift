//
//  ProfileVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    let ERROR_TITLE = NSLocalizedString("LogoutErrorTitle", comment: "The error title for logout errors")
    
    private var profileVM = ProfileVM(facebookAuthService: FacebookAuthService(), authService: FirebaseAuthService(), authErrorHandler: BasicAuthErrorHandler())
    
    @IBAction func logoutBtnTouched(_ sender: UIButton) {
        profileVM.logout { errorMessage in
            if let errorMessage = errorMessage {
                MessageAlertModalVC.present(withTitle: self.ERROR_TITLE, withMessage: errorMessage, fromVC: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//
//  ProfileVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    private var profileVM = ProfileVM()
    
    @IBAction func logoutBtnTouched(_ sender: UIButton) {
        profileVM.logout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

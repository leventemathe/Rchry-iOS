//
//  TargetVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 29..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class TargetsVC: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        MessageAlertModalVC.present(withTitle: "Hello", withMessage: "Bello", fromVC: self)
    }
}

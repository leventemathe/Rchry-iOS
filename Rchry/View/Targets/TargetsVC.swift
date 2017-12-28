//
//  TargetVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 29..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import RxCocoa

class TargetsVC: UIViewController {

    @IBAction func newTargetBtnTouched(_ sender: UIBarButtonItem) {
        let newTargetVC = UIStoryboard(name: "NewTarget", bundle: nil).instantiateViewController(withIdentifier: "NewTargetVC")
        navigationController?.pushViewController(newTargetVC, animated: true)
    }
}

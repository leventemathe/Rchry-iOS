//
//  MessageAlertModalVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 29..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import LMViews

class MessageAlertModalVC: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    
    var backgroundStartingOpacity: CGFloat = 0.0
    var backgroundFinalOpacity: CGFloat = 0.4
    
    var titleText: String!
    var message: String!
    
    @IBAction func okBtnTouched(_ sender: LMButton) {
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundView.alpha = self.backgroundStartingOpacity
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.alpha = backgroundFinalOpacity
        messageLbl.text = message
        titleLbl.text = titleText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundView.alpha = self.backgroundFinalOpacity
        })
    }
    
    static func present(withTitle title: String, withMessage message: String, fromVC vc: UIViewController) {
        let storyboard = UIStoryboard(name: "MessageAlertModal", bundle: nil)
        let modal = storyboard.instantiateViewController(withIdentifier: "MessageAlertModalVC") as! MessageAlertModalVC
        modal.message = message
        modal.titleText = title
        vc.present(modal, animated: true, completion: nil)
    }
}

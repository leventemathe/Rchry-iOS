//
//  SessionScoreSelectorHeaderView.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 25..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit

class SessionScoreSelectorHeaderView: UIView {

    @IBOutlet weak var titleLbl: UILabel!
    
    func update(title: String) {
        titleLbl.text = title
    }
}

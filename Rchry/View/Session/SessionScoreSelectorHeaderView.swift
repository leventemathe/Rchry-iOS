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
    
    private var index: Int!
    
    func update(_ index: Int, title: String) {
        self.index = index
        titleLbl.text = title
    }
}

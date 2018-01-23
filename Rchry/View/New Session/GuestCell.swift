//
//  GuestCell.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 23..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import LMViews

class GuestCell: UICollectionViewCell {
    
    @IBOutlet weak var guestNameLbl: LMLabel!
    
    func update(name: String) {
        guestNameLbl.text = name
    }
}

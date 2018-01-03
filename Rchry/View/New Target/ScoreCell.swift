//
//  ScoreCell.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 03..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import LMViews

class ScoreCell: UICollectionViewCell {
    
    @IBOutlet weak var scoreLbl: LMLabel!
    
    func update(_ score: String) {
        scoreLbl.text = score
    }
}

//
//  PickAnIconCell.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 03..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import LMViews

class PickAnIconCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: LMImageView!
    
    func update(_ image: UIImage) {
        imageView.image = image
    }
    
    func addBorder() {
        imageView.border = true
        imageView.borderColor = UIColor(named: "ColorThemeMid")!
        imageView.borderWidth = 2.0
    }
    
    func removeBorder() {
        imageView.border = false
    }
}

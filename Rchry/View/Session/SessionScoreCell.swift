//
//  SessionScoreCell.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 25..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit

class SessionScoreCell: ScoreCell {

    func setSelected() {
        scoreLbl.backgroundColor = UIColor(named: "ColorThemeBright")
        scoreLbl.textColor = UIColor.white
    }
    
    func setUnselected() {
        scoreLbl.backgroundColor = UIColor.clear
        scoreLbl.textColor = UIColor(named: "ColorThemeDark")
    }
}

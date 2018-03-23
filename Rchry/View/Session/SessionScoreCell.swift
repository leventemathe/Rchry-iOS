//
//  SessionScoreCell.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 25..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit

class SessionScoreCell: ScoreCell {

    private var _isScoreselected = false
    
    var isScoreSelected: Bool {
        return _isScoreselected
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setUnselected()
    }
    
    func setSelected() {
        if !isScoreSelected {
            // print("set selected called for lbl: \(scoreLbl.text ?? "")")
            scoreLbl.backgroundColor = UIColor(named: "ColorThemeBright")
            scoreLbl.textColor = UIColor.white
            scoreLbl.borderColor = .clear
            _isScoreselected = true
        }
    }
    
    func setUnselected() {
        if isScoreSelected {
            // print("set UNselected called for lbl: \(scoreLbl.text ?? "")")
            scoreLbl.backgroundColor = UIColor.clear
            scoreLbl.textColor = UIColor(named: "ColorThemeDark")
            scoreLbl.borderColor = UIColor(named: "ColorThemeMid")!
            _isScoreselected = false
        }
    }
}

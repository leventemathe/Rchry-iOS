//
//  PickerViewCell.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 04. 13..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit

class PickerViewCell: UIView {

    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = text
        }
    }
    private var text = ""
    
    func updateLabel(_ text: String) {
        self.text = text
    }
}

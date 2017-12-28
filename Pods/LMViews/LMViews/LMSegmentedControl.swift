//
//  LMSegmentedControl.swift
//  LMViews
//
//  Created by Máthé Levente on 2017. 12. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class LMSegmentedControl: UISegmentedControl {

    override func awakeFromNib() {
        
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 0.0 {
        didSet {
            setCornerRadius()
        }
    }
    
    private func setCornerRadius() {
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.masksToBounds = true
    }
    
    
    
    @IBInspectable
    open var border: Bool = false {
        didSet {
            if border {
                setBorder()
            } else {
                removeBorder()
            }
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable open var borderColor: UIColor = UIColor.black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    private func setBorder() {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
    
    private func removeBorder() {
        layer.borderWidth = 0.0
        layer.borderColor = nil
    }
    
    
    
    @IBInspectable
    open var font: String = UIFont.systemFont(ofSize: 17).familyName {
        didSet {
            setFont()
        }
    }
    
    @IBInspectable
    open var fontSize: CGFloat = 17.0 {
        didSet {
            setFont()
        }
    }
    
    private func setFont() {
        let attr: [AnyHashable: Any] = [
            NSAttributedStringKey.font: UIFont(name: font, size: fontSize)!
        ]
        setTitleTextAttributes(attr, for: .normal)
    }
}

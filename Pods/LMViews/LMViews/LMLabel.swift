//
//  LMLabel.swift
//  LMViews
//
//  Created by Máthé Levente on 2017. 12. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

open class LMLabel: UILabel {

    @IBInspectable open var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
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
    open var textPadding: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    open var textPaddingLeft: CGFloat = 0.0 {
        didSet {
            textPaddingInsets.left = textPaddingLeft
        }
    }
    
    @IBInspectable
    open var textPaddingRight: CGFloat = 0.0 {
        didSet {
            textPaddingInsets.right = textPaddingRight
        }
    }
    
    @IBInspectable
    open var textPaddingTop: CGFloat = 0.0 {
        didSet {
            textPaddingInsets.top = textPaddingTop
        }
    }
    
    @IBInspectable
    open var textPaddingBottom: CGFloat = 0.0 {
        didSet {
            textPaddingInsets.bottom = textPaddingBottom
        }
    }
    
    private var textPaddingInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    override open func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textPaddingInsets))
    }
    
    override open var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += textPaddingInsets.left + textPaddingInsets.right
        size.height += textPaddingInsets.top + textPaddingInsets.bottom
        return size
    }
}

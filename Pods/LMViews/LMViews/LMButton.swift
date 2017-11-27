//
//  LMButton.swift
//  LMViews
//
//  Created by Máthé Levente on 2017. 11. 16..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

@IBDesignable
open class LMButton: UIButton {
    
    @IBInspectable open  var shadow: Bool = false {
        didSet {
            if shadow {
                setShadow()
            } else {
                removeShadow()
            }
        }
    }
    
    @IBInspectable open var shadowColor: UIColor = UIColor.black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable open var shadowOpacity: Float = 1.0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable open var shadowOffset: CGSize = CGSize.zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable open var shadowRadius: CGFloat = 1.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    private func setShadow() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }
    
    private func removeShadow() {
        layer.shadowColor = nil
        layer.shadowOpacity = 0.0
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 0.0
    }
    
    
    
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
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    
    
    @IBInspectable
    open var gradient: Bool = false {
        didSet {
            if gradient {
                setGradient()
            } else {
                removeGradient()
            }
        }
    }
    
    @IBInspectable var gradientColorA: UIColor = UIColor.black {
        didSet {
            setGradient()
        }
    }
    
    @IBInspectable var gradientColorB: UIColor = UIColor.white {
        didSet {
            setGradient()
        }
    }
    
    private func setGradient() {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [gradientColorA.cgColor, gradientColorB.cgColor]
    }
    
    private func removeGradient() {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = nil
    }
}

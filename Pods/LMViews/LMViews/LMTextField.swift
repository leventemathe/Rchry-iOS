//
//  LMTextField.swift
//  LMViews
//
//  Created by Máthé Levente on 2017. 11. 18..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

open class LMTextField: UITextField, UITextFieldDelegate {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        delegate = self
    }
    
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
    open var backgroundColorForRoundedCorners: UIColor = UIColor.clear {
        didSet {
            layer.backgroundColor = backgroundColorForRoundedCorners.cgColor
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
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        if textPadding {
            return UIEdgeInsetsInsetRect(bounds, textPaddingInsets)
        } else {
            return super.textRect(forBounds: bounds)
        }
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        if textPadding {
            return UIEdgeInsetsInsetRect(bounds, textPaddingInsets)
        } else {
            return super.textRect(forBounds: bounds)
        }
    }
    
    
    
    @IBInspectable
    open var clearButton: UIImage? {
        didSet {
            if let img = clearButton {
                setClearButton(img)
            } else {
                removeClearButton()
            }
        }
    }
    
    @IBInspectable
    open var clearButtonPaddingRight: CGFloat = 0.0 {
        didSet {
            adjustClearButtonPadding()
        }
    }
    
    private func setClearButton(_ image: UIImage) {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        button.setImage(clearButton, for: .normal)
        button.addTarget(self, action: #selector(clearText(sender:)), for: UIControlEvents.touchUpInside)
        rightView = button
        
        self.clearButtonMode = .never
        self.rightViewMode = .whileEditing
    }
    
    private func removeClearButton() {
        rightView = nil
        self.rightViewMode = .never
    }
    
    private func adjustClearButtonPadding() {
        if let btn = rightView as? UIButton {
            btn.frame.size.width += clearButtonPaddingRight
            btn.imageEdgeInsets.right = clearButtonPaddingRight
            textPaddingInsets.right += clearButtonPaddingRight
        }
    }
    
    @objc func clearText(sender: UIButton) {
        text = ""
    }
    
    @IBInspectable
    open var paddingBetweenTextAndClearButton: CGFloat = 0.0 {
        didSet {
            adjustPaddingBetweenTextAndClearButton()
        }
    }
    
    private func adjustPaddingBetweenTextAndClearButton() {
        if let btn = rightView as? UIButton {
            btn.frame.size.width += paddingBetweenTextAndClearButton
            btn.imageEdgeInsets.left = paddingBetweenTextAndClearButton
            
            btn.frame.size.height += textPaddingInsets.bottom + textPaddingInsets.top
            btn.imageEdgeInsets.bottom = textPaddingInsets.bottom
            btn.imageEdgeInsets.top = textPaddingInsets.top
            
            textPaddingInsets.right += paddingBetweenTextAndClearButton
        }

    }
    
    
    
    @IBInspectable
    open var underlineWidth: CGFloat = 0.0
    
    @IBInspectable
    open var underlineColor: UIColor = UIColor.black
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if underlineWidth <= 0 {
            return
        }
        
        let start = CGPoint(x: rect.minX, y: rect.maxY)
        let end = CGPoint(x: rect.maxX, y: rect.maxY)
        let path = UIBezierPath()
        
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = underlineWidth
        underlineColor.setStroke()
        
        path.stroke()
    }
    
    
    
    @IBInspectable
    open var numbersOnly: Bool = false

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if numbersOnly {
            return checkForNumbersOnly(string)
        }
        return true
    }
    
    let numberPattern = "\\d+(\\.\\d*)?"
    
    private func checkForNumbersOnly(_ string: String) -> Bool {
        let newString = (text ?? "") + string
        let r1 = newString.startIndex..<newString.endIndex
        let r2 = newString.range(of: numberPattern, options: .regularExpression)
        return r1 == r2
    }
}

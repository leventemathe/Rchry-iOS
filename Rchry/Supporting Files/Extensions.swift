//
//  Extensions.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 03..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Float {
    
    func prettyString(_ locale: Locale = Locale.current) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal        
        numberFormatter.locale = locale
        if let result = numberFormatter.string(from: NSNumber(value: self)) {
            return result
        }
        return nil
    }
    
    func prettyString(minFractionDigits: Int, maxFractionDigits: Int, _ locale: Locale = Locale.current) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = minFractionDigits
        numberFormatter.maximumFractionDigits = maxFractionDigits
        numberFormatter.locale = locale
        if let result = numberFormatter.string(from: NSNumber(value: self)) {
            return result
        }
        return nil
    }
    
    func dashSeparatedString(_ locale: Locale = Locale.current) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = locale
        
        if let result = numberFormatter.string(from: NSNumber(value: self)), let decimalSeparator = locale.decimalSeparator {
            let subStrings = result.split(separator: Character(decimalSeparator))
            if subStrings.count >= 2 {
                return String(subStrings[0]) + "-" + String(subStrings[1])
            } else if subStrings.count >= 1 {
                return String(subStrings[0])
            }
        }
        return nil
    }
}

extension String {
    
    func float(_ locale: Locale = Locale.current) -> Float? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = locale
        if let result =  numberFormatter.number(from: self) {
            return result.floatValue
        }
        return nil
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

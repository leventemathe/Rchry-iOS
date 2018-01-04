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
    
    var prettyString: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        if let result = numberFormatter.string(from: NSNumber(value: self)) {
            return result
        }
        return nil
    }
}

extension String {
    
    var float: Float? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        if let result =  numberFormatter.number(from: self) {
            return result.floatValue
        }
        return nil
    }
}

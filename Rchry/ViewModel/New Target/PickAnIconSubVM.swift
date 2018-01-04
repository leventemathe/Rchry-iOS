//
//  PickAnIconVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 03..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

class PickAnIconSubVM {
    
    let images = ["target", "deer", "bear", "ram", "wolf"]
    
    private var _selectedImage: Int?
    
    var selectedImage: Int? {
        get {
            if let selected = _selectedImage {
                if 0..<images.count ~= selected {
                    return _selectedImage
                }
                return nil
            }
            return nil
        }
        set {
            _selectedImage = newValue
        }
    }
    
    func isSelected(_ index: Int) -> Bool {
        if let selected = _selectedImage {
            if index == selected {
                return true
            }
            return false
        }
        return false
    }
}

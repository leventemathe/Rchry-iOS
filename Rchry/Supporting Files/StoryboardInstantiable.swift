//
//  StoryboardInstantiable.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 11. 13..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit

protocol StoryboardInstantiable {
    
    static func instantiate() -> Self
}

extension StoryboardInstantiable where Self: UIViewController {
    
    static func instantiate() -> Self {
        let vcID = String(NSStringFromClass(self).split(separator: ".")[1])
        let storyboardName = String(vcID.dropLast(2))
        let sb = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return sb.instantiateViewController(withIdentifier: vcID) as! Self
    }
}

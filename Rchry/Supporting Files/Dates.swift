//
//  Dates.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 24..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

protocol DateProvider {
    
    var currentTimestamp: Double { get }
    func dateString(fromTimestamp timestamp: Double) -> String
}

struct BasicDateProvider: DateProvider {
    
    private let locale: Locale
    
    init(locale: Locale = Locale.current) {
        self.locale = locale
    }
    
    var currentTimestamp: Double {
        return Date().timeIntervalSince1970
    }
    
    func dateString(fromTimestamp timestamp: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateStyle = .short
        let date = Date(timeIntervalSince1970: timestamp)
        return dateFormatter.string(from: date)
    }
}

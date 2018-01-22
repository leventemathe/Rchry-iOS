//
//  DatabaseError.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 04..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

enum DatabaseError: Error {
    case network
    case server
    case json
    case tooManyRequests
    case other
}



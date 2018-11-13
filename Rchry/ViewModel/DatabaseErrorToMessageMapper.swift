//
//  DatabaseErrorHandler.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 09..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

protocol DatabaseErrorToMessageMapper {
    
    var ERROR_NEWTORK: String {
        get
    }
    var ERROR_SERVER: String {
        get
    }
    var ERROR_TOO_MANY_REQUESTS: String {
        get
    }
    var ERROR_OTHER: String {
        get
    }
    
    func map(error: DatabaseError) -> String
}

struct BasicDatabaseErrorToMessageMapper: DatabaseErrorToMessageMapper {
    
    var ERROR_NEWTORK: String {
        return NSLocalizedString("A database error occured", comment: "A network error happened while accessing the database.")
    }
    var ERROR_SERVER: String {
        return NSLocalizedString("A server error occured", comment: "A server error happened while accessing the database.")
    }
    var ERROR_TOO_MANY_REQUESTS: String {
        return NSLocalizedString("Too many requests, please slow down", comment: "Too many requests, please slow down.")
    }
    var ERROR_OTHER: String {
        return NSLocalizedString("Unknown database error", comment: "Some other, unknown error happened while accessing the database.")
    }
    
    func map(error: DatabaseError) -> String {
        switch error {
        case .network:
            return ERROR_NEWTORK
        case .server, .json:
            return ERROR_SERVER
        case .tooManyRequests:
            return ERROR_TOO_MANY_REQUESTS
        default:
            return ERROR_OTHER
        }
    }
}

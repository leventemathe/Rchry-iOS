//
//  DatabaseErrorHandler.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 09..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

protocol DatabaseErrorHandler {
    
    var ERROR_NEWTORK: String {
        get
    }
    var ERROR_SERVER: String {
        get
    }
    var ERROR_OTHER: String {
        get
    }
    
    func handle(error: DatabaseError) -> String
}

struct BasicDatabaseErrorHandler: DatabaseErrorHandler {
    
    var ERROR_NEWTORK: String {
        return NSLocalizedString("DatabaseNetworkError", comment: "A network error happened while accessing the database.")
    }
    var ERROR_SERVER: String {
        return NSLocalizedString("DatabaseServerError", comment: "A server error happened while accessing the database.")
    }
    var ERROR_OTHER: String {
        return NSLocalizedString("DatabaseOtherError", comment: "Some other, unknown error happened while accessing the database.")
    }
    
    func handle(error: DatabaseError) -> String {
        switch error {
        case .network:
            return ERROR_NEWTORK
        case .server, .json:
            return ERROR_SERVER
        default:
            return ERROR_OTHER
        }
    }
}

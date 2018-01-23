//
//  TargetsVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 22..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

class TargetsVM {
    
    private let targetService: TargetService
    private let databaseErrorMapper: DatabaseErrorToMessageMapper
    
    init(targetService: TargetService = FirebaseTargetService(),
         databaseErrorMapper: DatabaseErrorToMessageMapper = BasicDatabaseErrorToMessageMapper()) {
        self.targetService = targetService
        self.databaseErrorMapper = databaseErrorMapper
    }
    
    var targets: Observable<([Target]?, String?)> {
        return targetService.observeTargets()
            .map { ($0, nil) }
            .catchError { [unowned self] error in
                let errorString = self.databaseErrorMapper.map(error: error as! DatabaseError)
                return Observable.just((nil, errorString))
            }
    }
}

//
//  FirebaseAuthServiceTest.swift
//  RchryTests
//
//  Created by Máthé Levente on 2017. 12. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import Rchry
import Firebase

class FirebaseAuthServiceTest: XCTestCase {
    
    private var firebaseAuth: FirebaseAuthMock!
    private var firebaseAuthService: FirebaseAuthService!
    
    override func setUp() {
        super.setUp()
        firebaseAuth = FirebaseAuthMock()
    }
    
    override func tearDown() {
        firebaseAuthService = nil
        firebaseAuth = nil
        super.tearDown()
    }
    
    private func createFirebaseAuthService() {
        firebaseAuthService = FirebaseAuthService(firebaseAuth: firebaseAuth)
    }
    
    func testLoginSuccess() {
        createFirebaseAuthService()
        firebaseAuthService.login(.facebook, withToken: "asd", withCompletion: { error in
            XCTAssert(error == nil, "testLoginSuccess")
        })
    }
}

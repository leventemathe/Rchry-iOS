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
    
    func testLoginSuccessful() {
        createFirebaseAuthService()
        firebaseAuthService.login(.facebook, withToken: "asd", withCompletion: { error in
            XCTAssert(error == nil, "testLoginSuccessful")
        })
    }
    
    func testLoginErrorHappened() {
        firebaseAuth.error = NSError()
        createFirebaseAuthService()
        firebaseAuthService.login(.facebook, withToken: "asd", withCompletion: { error in
            XCTAssert(error != nil, "testLoginErrorHappened")
        })
    }
    
    func testLogoutSuccessful() {
        createFirebaseAuthService()
        firebaseAuthService.logout { error in
            XCTAssert(error == nil, "testLogoutSuccessful")
        }
    }
    
    func testLogoutErrorHappened() {
        firebaseAuth.error = NSError()
        createFirebaseAuthService()
        firebaseAuthService.logout { error in
            XCTAssert(error != nil, "testLogoutErrorHappened")
        }
    }
    
    func testDeleteSuccesful() {
        createFirebaseAuthService()
        firebaseAuthService.deleteUser { error in
            XCTAssert(error == nil, "testDeleteSuccesful")
        }
    }
    
    func testDeleteErrorHappened() {
        firebaseAuth.error = NSError()
        createFirebaseAuthService()
        firebaseAuthService.deleteUser { error in
            XCTAssert(error != nil, "testDeleteErrorHappened")
        }
    }
}

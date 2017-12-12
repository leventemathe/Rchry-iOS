//
//  FacebookAuthServiceTest.swift
//  RchryTests
//
//  Created by Máthé Levente on 2017. 12. 12..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import Rchry
import FBSDKLoginKit

class FacebookAuthServiceTest: XCTestCase {
    
    private var loginManager: FacebookLoginManagerMock!
    private var facebookAuthService: FacebookAuthService!
    
    override func setUp() {
        super.setUp()
        loginManager = FacebookLoginManagerMock()
    }
    
    override func tearDown() {
        loginManager = nil
        facebookAuthService = nil
    }
    
    private func createFacebookAuthService() {
        facebookAuthService = FacebookAuthService(loginManager)
    }
    
    private func createToken() -> FBSDKAccessToken {
        return FBSDKAccessToken(tokenString: "asd", permissions: nil, declinedPermissions: nil, appID: nil, userID: nil, expirationDate: nil, refreshDate: nil)
    }
    
    func testLoginSuccesful() {
        loginManager.result = FBSDKLoginManagerLoginResult(token: createToken(), isCancelled: false, grantedPermissions: nil, declinedPermissions: nil)
        createFacebookAuthService()
        facebookAuthService.login { (error, token) in
            XCTAssert(error == nil, "testLoginSuccesful")
        }
    }
    
    func testLoginErrorHappened() {
        loginManager.error = NSError()
        createFacebookAuthService()
        facebookAuthService.login { (error, token) in
            XCTAssert(error != nil, "testLoginErrorHappened")
        }
    }
    
    func testLoginPermissionDeclined() {
        loginManager.result = FBSDKLoginManagerLoginResult(token: createToken(), isCancelled: false, grantedPermissions: nil, declinedPermissions: ["public_profile"])
        createFacebookAuthService()
        facebookAuthService.login { (error, token) in
            if let error = error {
                if case AuthError.permissionDenied = error {
                    XCTAssert(true, "testLoginPermissionDeclined")
                } else {
                    XCTAssert(false, "testLoginPermissionDeclined")
                }
            } else {
                XCTAssert(false, "testLoginPermissionDeclined, error was nil")
            }
            XCTAssert(token == nil, "testLoginPermissionDeclined")
        }
    }
    
    func testLoginCancelled() {
        loginManager.result = FBSDKLoginManagerLoginResult(token: nil, isCancelled: true, grantedPermissions: nil, declinedPermissions: nil)
        createFacebookAuthService()
        facebookAuthService.login { (error, token) in
            if let error = error {
                if case AuthError.cancelled = error {
                    XCTAssert(true, "testLoginCancelled")
                } else {
                    XCTAssert(false, "testLoginCancelled")
                }
            } else {
                XCTAssert(false, "testLoginCancelled, error was nil")
            }
        }
    }
    
    func testLoginTokenMissing() {
        loginManager.result = FBSDKLoginManagerLoginResult(token: nil, isCancelled: false, grantedPermissions: nil, declinedPermissions: nil)
        createFacebookAuthService()
        facebookAuthService.login { (error, token) in
            if let error = error {
                if case AuthError.other = error {
                    XCTAssert(true, "testLoginTokenMissing")
                } else {
                    XCTAssert(false, "testLoginTokenMissing")
                }
            } else {
                XCTAssert(false, "testLoginTokenMissing, error was nil")
            }
        }
    }
}

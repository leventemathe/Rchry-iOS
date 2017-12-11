//
//  LoginVMTest.swift
//  RchryTests
//
//  Created by Máthé Levente on 2017. 12. 06..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import Rchry

class LoginVMTest: XCTestCase {

    var facebookService: FacebookAuthServiceMock!
    var authService: AuthServiceMock!
    var authErrorHandler: BasicAuthErrorHandler!
    
    var loginVM: LoginVM!
    
    let facebookToken = "asd"
    
    override func setUp() {
        super.setUp()
        facebookService = FacebookAuthServiceMock()
        authService = AuthServiceMock()
        authErrorHandler = BasicAuthErrorHandler()
        
        facebookService.token = facebookToken
    }
    
    override func tearDown() {
        super.tearDown()
        facebookService = nil
        authService = nil
        authErrorHandler = nil
        
        loginVM = nil
    }
    
    private func createLoginVM(withFacebookError facebookError: AuthError?, withAuthError authError: AuthError?) {
        facebookService.error = facebookError
        authService.error = authError
        loginVM = LoginVM(facebookAuthService: facebookService, authService: authService, authErrorHandler: authErrorHandler)
    }
    
    func testLoginSuccessful() {
        createLoginVM(withFacebookError: nil, withAuthError: nil)
        loginVM.loginWithFacebook({ errorMessage in
            XCTAssert(errorMessage == nil, "LoginSuccesful")
        })
    }
    
    func testLoginFacebookNetworkError() {
        createLoginVM(withFacebookError: .network, withAuthError: nil)
        loginVM.loginWithFacebook({ errorMessage in
            XCTAssert(errorMessage == self.loginVM.authErrorHandler.ERROR_NETWORK, "LoginFacebookNetworkError")
        })
    }
    
    func testLoginAuthNetworkError() {
        createLoginVM(withFacebookError: nil, withAuthError: .network)
        loginVM.loginWithFacebook({ errorMessage in
            XCTAssert(errorMessage == self.loginVM.authErrorHandler.ERROR_NETWORK, "LoginAuthNetworkError")
        })
    }
}






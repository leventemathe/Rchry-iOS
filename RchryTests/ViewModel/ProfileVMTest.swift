//
//  ProfileVMTest.swift
//  RchryTests
//
//  Created by Máthé Levente on 2017. 12. 11..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import XCTest
@testable import Rchry

class ProfileVMTest: XCTestCase {
    
    var facebookService: FacebookAuthServiceMock!
    var authService: AuthServiceMock!
    var authErrorHandler: BasicAuthErrorHandler!
    
    var profileVM: ProfileVM!
    
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
        
        profileVM = nil
    }
    
    private func createProfileVM(withFacebookError facebookError: AuthError?, withAuthError authError: AuthError?) {
        facebookService.error = facebookError
        authService.error = authError
        profileVM = ProfileVM(facebookAuthService: facebookService, authService: authService, authErrorHandler: authErrorHandler)
    }
    
    func testLogoutSuccessful() {
        createProfileVM(withFacebookError: nil, withAuthError: nil)
        profileVM.logout { errorMessage in
            XCTAssert(errorMessage == nil, "LogoutSuccesful")
        }
    }
    
    func testLogoutFacebookNetworkError() {
        createProfileVM(withFacebookError: .network, withAuthError: nil)
        profileVM.logout { errorMessage in
            XCTAssert(errorMessage == self.profileVM.authErrorHandler.ERROR_NETWORK, "LogoutFacebookNetworkError")
        }
    }
    
    func testLogoutAuthNetworkError() {
        createProfileVM(withFacebookError: nil, withAuthError: .network)
        profileVM.logout { errorMessage in
            XCTAssert(errorMessage == self.profileVM.authErrorHandler.ERROR_NETWORK, "LogoutAuthNetworkError")
        }
    }
}

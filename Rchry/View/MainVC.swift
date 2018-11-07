//
//  MainVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 12. 22..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    
    var authService = FirebaseAuthService()
    
    private lazy var loginVC: UIViewController = {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = loginStoryboard.instantiateViewController(withIdentifier: "LoginVC")
        return vc
    }()
    
    private lazy var targetsNavigationVC: UIViewController = {
        let targetsStoryboard = UIStoryboard(name: "Targets", bundle: nil)
        let vc = targetsStoryboard.instantiateViewController(withIdentifier: "TargetsNavigationVC")
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decideVC()
    }
    
    func decideVC() {
        if authService.isLoggedIn{
            if !children.contains(targetsNavigationVC) {
                setTargetsNavigationVC()
            }
        } else {
            if !children.contains(loginVC) {
                setLoginVC()
            }
        }
    }
    
    func setLoginVC() {
        unset(vc: targetsNavigationVC)
        set(vc: loginVC)
    }
    
    func setTargetsNavigationVC() {
        unset(vc: loginVC)
        set(vc: targetsNavigationVC)
    }
    
    private func set(vc: UIViewController) {
        addChild(vc)
        vc.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func unset(vc: UIViewController) {
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let _ = children.first as? LoginVC {
            return .lightContent
        } else {
            return .default
        }
    }
}

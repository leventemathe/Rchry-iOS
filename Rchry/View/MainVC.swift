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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func decideVC() {
        if authService.isLoggedIn{
            if !childViewControllers.contains(targetsNavigationVC) {
                setTargetsNavigationVC()
            }
        } else {
            if !childViewControllers.contains(loginVC) {
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
        addChildViewController(vc)
        vc.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
    
    private func unset(vc: UIViewController) {
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
}

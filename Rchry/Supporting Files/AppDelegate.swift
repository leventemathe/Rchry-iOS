//
//  AppDelegate.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 23..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    private var mainVC = MainVC()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        setupFirebase()
        setupGlobalViews()        
        decideInitialVC()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        return handled
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        let userSession = FirebaseAuthService()
        if let uid = userSession.userID {
            Database.database().reference(withPath: uid).keepSynced(true)
        }
    }
    
    private func setupGlobalViews() {
        let navBarFont = UIFont(name: "Amatic-Bold", size: 24)!
        let navBarTitleFont = UIFont(name: "Amatic-Bold", size: 28)!
        UINavigationBar.appearance().titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor(named: "ColorThemeDark")!,
             NSAttributedString.Key.font: navBarTitleFont]
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: navBarFont], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: navBarFont], for: .selected)
    }
    
    private func decideInitialVC() {
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
    }
    
    private func decideVC() {
        mainVC.decideVC()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        decideVC()
    }
}


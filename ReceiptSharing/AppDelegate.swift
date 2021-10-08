//
//  AppDelegate.swift
//  ReceiptSharing
//
//  Created by Daniil Novoselov on 08.10.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #warning("TODO: определить логику")
        setupAppearance()
        
        let isMaster = true
        
        if isMaster {
            let window = UIWindow()
            window.makeKeyAndVisible()
            let vc = MasterStartPageViewController()
            let navController = UINavigationController(rootViewController: vc)
            window.rootViewController = navController
            self.window = window
            window.makeKeyAndVisible()
        } else {
            
        }
        
        return true
    }

    private func setupAppearance() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = nil
        navBarAppearance.shadowColor = nil
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        guard let traitCollection = window?.traitCollection else { return }
        let appearance = UINavigationBar.appearance(for: traitCollection)
        appearance.standardAppearance = navBarAppearance
        appearance.scrollEdgeAppearance = navBarAppearance
        appearance.compactAppearance = navBarAppearance
        appearance.tintColor = .white
    }


}


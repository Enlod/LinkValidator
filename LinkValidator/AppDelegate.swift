//
//  AppDelegate.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 14.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let linkTableViewController =
            LinkTableViewController(
                viewModel: LinkListViewModelImpl(
                    linkListProvider: TestAPILinkListRequest(
                        urlSession: URLSession(configuration: .default)),
                        linkIsFavoriteRepository: LinkIsFavoriteRepositoryImpl()))
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.rootViewController = linkTableViewController
        window.makeKeyAndVisible()
        
        return true
    }
}


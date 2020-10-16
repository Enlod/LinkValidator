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
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.rootViewController = Self._buildRootViewController()
        window.makeKeyAndVisible()
        
        return true
    }
    
    private static func _buildRootViewController() -> UIViewController {
        
        let linkListProvider = TestAPILinkListRequest(
            httpRequest: HTTPRequestImpl(
                urlSession: TestAPILinkListRequest.session))
        
        let linkValidatorFactory = {
            LinkHTTPResponseCodeValidationRequest(
                httpRequest: HTTPRequestImpl(
                    urlSession: LinkHTTPResponseCodeValidationRequest.session))
        }
        
        let linkListViewModel =
            LinkListViewModelImpl(
                linkListProvider: linkListProvider,
                linkIsFavoriteRepository: LinkIsFavoriteRepositoryImpl(),
                linkValidatorFactory: linkValidatorFactory)
        
        return LinkTableViewController(viewModel: linkListViewModel)
    }
}


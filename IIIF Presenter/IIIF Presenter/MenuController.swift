//
//  MenuController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 01/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class MenuController: UITabBarController {

    var launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeControllers()
    }
    
    func initializeControllers() {
        let historyController = viewControllers?.first as! CardListController
        let searchController = viewControllers?.last as! CardListController
        
        historyController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
        searchController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        searchController.viewModel = CollectionViewModel.createWithUrl(Constants.testUrl, searchController)
        if let url = launchOptions?[.url] as? URL {
            historyController.viewModel = CollectionViewModel.createWithUrl(url.absoluteString, historyController)
        } else {
            // show search tab if no launch options url available
            selectedIndex = 1
            selectedViewController = searchController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

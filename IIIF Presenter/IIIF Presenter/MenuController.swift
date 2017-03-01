//
//  MenuController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 01/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class MenuController: UITabBarController {

    var searchCollection: IIIFCollection!
    var historyCollection: IIIFCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeControllers()
    }
    
    func initializeControllers() {
        let historyController = viewControllers?.first as! CardListController
        let searchController = viewControllers?.last as! CardListController
        
        historyController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
        searchController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        searchController.viewModel = CollectionViewModel(searchCollection)
        
        if historyCollection != nil {
            historyController.viewModel = CollectionViewModel(historyCollection!)
        } else {
            // show search tab if no history data available
            selectedIndex = 1
            selectedViewController = searchController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//
//  MenuController.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 01/03/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

class MenuController: UITabBarController {

    var showHistory = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeControllers()
    }
    
    func initializeControllers() {
        let historyController = viewControllers?.first as! CardListController
        let searchController = viewControllers?.last as! CardListController
        let historyManifests = getHistoryManifests()
        
        historyController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
        searchController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        searchController.viewModel = CollectionViewModel.createWithUrl(Constants.testUrl, delegate: searchController)
        historyController.viewModel = CollectionViewModel(IIIFCollection.createCollectionWith(historyManifests))
        
        if !showHistory {
            // show search tab if no launch options url available
            showSearchTab()
        }
    }
    
    func showSearchTab() {
        selectedIndex = 1
        selectedViewController = viewControllers?[selectedIndex]
    }
    
    func showHistoryTab() {
        let historyController = viewControllers?.first as! CardListController
        let historyManifests = getHistoryManifests()
        if historyController.viewModel?.manifestCount != historyManifests.count {
            historyController.viewModel = CollectionViewModel(IIIFCollection.createCollectionWith(historyManifests))
        }
        
        selectedIndex = 0
        selectedViewController = viewControllers?[selectedIndex]
    }
    
    func getHistoryManifests() -> [IIIFManifest] {
        var historyManifests = [IIIFManifest]()
        if let history = UserDefaults.standard.stringArray(forKey: Constants.historyKey) {
            for s in history {
                if let m = IIIFManifest(id: s) {
                    historyManifests.append(m)
                }
            }
        }
        return historyManifests
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

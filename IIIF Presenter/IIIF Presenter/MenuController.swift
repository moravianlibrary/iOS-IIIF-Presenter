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
    var showHistoryError = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeControllers()
    }
    
    func initializeControllers() {
        let historyController = viewControllers?.first as! CardListController
        let searchController = viewControllers?.last as! CardListController
        let historyManifests = getHistoryItems()
        
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
        historyController.showFirstError = showHistoryError
        let historyManifests = getHistoryItems()
        if historyController.viewModel?.itemsCount != historyManifests.count {
            historyController.viewModel = CollectionViewModel(IIIFCollection.createCollectionWith(historyManifests))
        }
        
        selectedIndex = 0
        selectedViewController = viewControllers?[selectedIndex]
    }
    
    func getHistoryItems() -> [Any] {
        var historyItems = [Any]()
        if let history = UserDefaults.standard.stringArray(forKey: Constants.historyUrlKey),
            let types = UserDefaults.standard.stringArray(forKey: Constants.historyTypeKey) {
            for (i, id) in history.enumerated() {
                if types[i] == IIIFManifest.type, let m = IIIFManifest(id: id) {
                    historyItems.append(m)
                } else if types[i] == IIIFCollection.type, let c = IIIFCollection(id: id) {
                    historyItems.append(c)
                } else {
                    // unknown type
                    historyItems.append(id)
                }
            }
        }
        return historyItems
    }
}

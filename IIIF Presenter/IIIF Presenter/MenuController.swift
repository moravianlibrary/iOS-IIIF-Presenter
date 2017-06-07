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
    
    fileprivate let dummyUrl = URL(string:"www.google.com")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iOS 9 and less tab bar item coloring
        UITabBar.appearance().tintColor = Constants.greenColor
        
        initializeControllers()
    }
    
    func initializeControllers() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let historyController = storyboard.instantiateViewController(withIdentifier: CardListController.id) as! CardListController
        let searchController = storyboard.instantiateViewController(withIdentifier: CardListController.id) as! CardListController
        let aboutController = storyboard.instantiateViewController(withIdentifier: AboutController.id) as! AboutController
        let historyManifests = getHistoryItems()
        
        searchController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        historyController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 1)
        aboutController.tabBarItem = UITabBarItem(title: NSLocalizedString("about", comment: ""), image: UIButton(type: .infoLight).image(for: .normal), tag: 2)
        historyController.isHistory = true
        
        searchController.viewModel = CollectionViewModel.createWithUrl(Constants.testUrl, delegate: searchController)
        historyController.viewModel = CollectionViewModel(IIIFCollection.createCollectionWith(dummyUrl, members: historyManifests))
        
        setViewControllers([searchController, historyController, aboutController], animated: false)
        
        if showHistory {
            // show search tab if no launch options url available
            showHistoryTab()
        }
    }
    
    func showSearchTab() {
        selectedIndex = 0
        selectedViewController = viewControllers?[selectedIndex]
    }
    
    func showHistoryTab() {
        let historyController = viewControllers?.first as! CardListController
        historyController.showFirstError = showHistoryError
        let historyManifests = getHistoryItems()
        if historyController.viewModel?.itemsCount != historyManifests.count {
            historyController.viewModel = CollectionViewModel(IIIFCollection.createCollectionWith(dummyUrl, members: historyManifests))
        }
        
        selectedIndex = 1
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

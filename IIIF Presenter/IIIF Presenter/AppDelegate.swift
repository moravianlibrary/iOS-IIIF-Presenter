//
//  AppDelegate.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var wasLaunchedWithUrl = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        initConstants()
        
        if let urlString = (launchOptions?[.url] as? URL)?.absoluteString {
            print("Launch options: \(launchOptions!).")
            
            if var array = UserDefaults.standard.stringArray(forKey: Constants.historyKey) {
                array.append(urlString)
                UserDefaults.standard.set(array, forKey: Constants.historyKey)
            } else {
                UserDefaults.standard.set([urlString], forKey: Constants.historyKey)
            }
            
            let navController = window?.rootViewController as? UINavigationController
            let menuController = navController?.topViewController as? MenuController
            menuController?.showHistory = true
        } else {
            print("Launch options is empty.")
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // TODO: add support for other IIIF types, such as Collection or single Canvas
        let regex = "^https?://.+?/manifest$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let urlString = String(url.absoluteString.characters.dropFirst(5))
        
        guard predicate.evaluate(with: urlString) else {
            print("Regular expression does not match.")
            return false
        }
        
        if var array = UserDefaults.standard.stringArray(forKey: Constants.historyKey) {
            if !array.contains(urlString) {
                array.append(urlString)
                UserDefaults.standard.set(array, forKey: Constants.historyKey)
            }
        } else {
            UserDefaults.standard.set([urlString], forKey: Constants.historyKey)
        }
        wasLaunchedWithUrl = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if wasLaunchedWithUrl {
            let navController = window?.rootViewController as? UINavigationController
            let menuController = navController?.topViewController as? MenuController
            menuController?.showHistoryTab()
            wasLaunchedWithUrl = false
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    fileprivate func initConstants() {
        Constants.isIPhone = UIDevice.current.model.contains("iPhone")
        
        let screenWidth = UIScreen.main.bounds.width
        Constants.cardsPerRow = screenWidth >= 1000.0 ? 3 : (screenWidth >= 500.0 ? 2 : 1)
        if let lang = Locale.current.languageCode {
            Constants.lang = lang
        }
        
        Constants.printDescription()
    }
}


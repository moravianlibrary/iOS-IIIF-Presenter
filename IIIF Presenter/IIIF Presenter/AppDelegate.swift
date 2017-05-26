//
//  AppDelegate.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import UIKit
import SDWebImage
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    fileprivate var wasLaunchedWithUrl = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        initConstants()
        
        // init image cache
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
        SDImageCache.shared().config.shouldDecompressImages = false
        
        // init logging
        // TODO: differ log level by scheme - at least devel/release
        DDLog.add(DDTTYLogger.sharedInstance, with: .verbose) // TTY = Xcode console
        DDLog.add(DDASLLogger.sharedInstance) // ASL = Apple System Logs
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        
        if let urlString = (launchOptions?[.url] as? URL)?.absoluteString {
            log("Launch options: \(launchOptions!).", level: .Verbose)
            
            addToUserDefaults(urlString)
            let navController = window?.rootViewController as? UINavigationController
            let menuController = navController?.topViewController as? MenuController
            menuController?.showHistory = true
            menuController?.showHistoryError = true
        } else {
            log("Launch options is empty.", level: .Verbose)
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
//        let regex = "^https?://.+?/manifest$"
//        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let urlString = String(url.absoluteString.characters.dropFirst(5)) // drop application url scheme
        
        guard let _ = URL(string: urlString) else {
            log("Url is not valid.", level: .Verbose)
            return false
        }
        
        addToUserDefaults(urlString)
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
            menuController?.showHistoryError = true
            menuController?.showHistoryTab()
            wasLaunchedWithUrl = false
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func log(_ message: String, level: LogLevel) {
        switch level {
        case .Verbose:
            DDLogVerbose(message)
        case .Debug:
            DDLogDebug(message)
        case .Info:
            DDLogInfo(message)
        case .Warn:
            DDLogWarn(message)
        case .Error:
            DDLogError(message)
        }
    }
    
    func addToUserDefaults(_ urlString: String) {
        if var values = UserDefaults.standard.stringArray(forKey: Constants.historyUrlKey), var types = UserDefaults.standard.stringArray(forKey: Constants.historyTypeKey) {
            if !values.contains(urlString) {
                values.insert(urlString, at: 0)
                types.insert("unknown", at: 0)
                UserDefaults.standard.set(values, forKey: Constants.historyUrlKey)
                UserDefaults.standard.set(types, forKey: Constants.historyTypeKey)
            }
        } else {
            UserDefaults.standard.set([urlString], forKey: Constants.historyUrlKey)
            UserDefaults.standard.set(["unknown"], forKey: Constants.historyTypeKey)
        }
    }
    
    func updateUserDefaults(_ item: Any) {
        let type = item is IIIFManifest ? IIIFManifest.type : IIIFCollection.type
        let id = item is IIIFManifest ? (item as! IIIFManifest).id.absoluteString : (item as! IIIFCollection).id.absoluteString
        if let values = UserDefaults.standard.stringArray(forKey: Constants.historyUrlKey),
            var types = UserDefaults.standard.stringArray(forKey: Constants.historyTypeKey) {
            
            var changed = false
            for (index, url) in values.enumerated() where url == id {
                types[index] = type
                changed = true
            }
            
            if changed {
                UserDefaults.standard.set(types, forKey: Constants.historyTypeKey)
            }
        }
    }
    
    func deleteUserDefaults(_ item: String) {
        if var values = UserDefaults.standard.stringArray(forKey: Constants.historyUrlKey),
            var types = UserDefaults.standard.stringArray(forKey: Constants.historyTypeKey) {
            
            var changed = false
            for (index, url) in values.enumerated() where url == item {
                changed = true
                values.remove(at: index)
                types.remove(at: index)
            }
            
            if changed {
                UserDefaults.standard.set(values, forKey: Constants.historyUrlKey)
                UserDefaults.standard.set(types, forKey: Constants.historyTypeKey)
            }
        }
    }
    
    fileprivate func initConstants() {
        Constants.appDelegate = self
        Constants.isIPhone = UIDevice.current.model.contains("iPhone")
        Constants.dateFormatter.dateFormat = "DD.MM.YYYY hh:mm:ss"
        
        if let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            
            Constants.version = "\(versionNumber) (\(buildNumber))"
        }
        
        if Constants.isIPhone {
            Constants.cardsPerRow = 1
        } else {
            var num = Int(ceil(UIScreen.main.bounds.width / 500.0))
            if UIDevice.current.orientation.isLandscape {
                num -= 1
            }
            Constants.cardsPerRow = num
        }
        
        if let lang = Locale.current.languageCode {
            Constants.lang = lang
        }
        
        Constants.printDescription()
    }
}

func log(_ message: String) {
    log(message, level: .Verbose)
}

func log(_ message: String, level: LogLevel) {
    Constants.appDelegate.log(message, level: level)
}

enum LogLevel {
    case Verbose
    case Debug
    case Info
    case Warn
    case Error
}

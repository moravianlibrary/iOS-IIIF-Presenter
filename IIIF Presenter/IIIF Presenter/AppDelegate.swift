//
//  AppDelegate.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 02/02/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//

import CocoaLumberjack
import Crashlytics
import Fabric
import SDWebImage
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    fileprivate var wasLaunchedWithUrl = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

//        UserDefaults.standard.removeObject(forKey: Constants.historyTypeKey)
//        UserDefaults.standard.removeObject(forKey: Constants.historyUrlKey)

        #if RELEASE
            // init analytics
            AnalyticsUtil.initAnalytics()
            // init crashlytics
            Fabric.with([Crashlytics.self])
        #endif

        initConstants()

        // init image cache
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
        SDImageCache.shared().config.shouldDecompressImages = false
        SDImageCache.shared().config.maxCacheAge = 60 * 60 * 24 * 7     // week
        SDImageCache.shared().deleteOldFiles(completionBlock: nil)

        // init logging
        #if DEBUG
            print("This is DEBUG version.")
            DDLog.add(DDTTYLogger.sharedInstance, with: .verbose) // TTY = Xcode console
        #else
            print("This is RELEASE version.")
            DDLog.add(DDTTYLogger.sharedInstance, with: .info)
            DDLog.add(DDASLLogger.sharedInstance, with: .info) // ASL = Apple System Logs

            let fileLogger: DDFileLogger = DDFileLogger()
            fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
            fileLogger.logFileManager.maximumNumberOfLogFiles = 7
            DDLog.add(fileLogger, with: .info)
        #endif

        setInitialViewController()

        if var urlString = (launchOptions?[.url] as? URL)?.absoluteString {
            log("Launch options: \(String(describing: launchOptions)).", level: .Verbose)

            if urlString.hasPrefix("iiif:"), let index = urlString.index(of: ":") {
                let range = urlString.startIndex...index
                urlString.replaceSubrange(range, with: "")
            }

            addToUserDefaults(urlString)
        } else {
            log("Launch options is empty.", level: .Verbose)
        }

        return true
    }

    // openURL on iOS 9+
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {

        let urlString = String(url.absoluteString.dropFirst(5)) // drop application url scheme

        guard URL(string: urlString) != nil else {
            log("Url is not valid.", level: .Error)
            return false
        }

        addToUserDefaults(urlString)
        wasLaunchedWithUrl = true

        return true
    }

    // openURL on iOS 8
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.application(application, open: url)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        if wasLaunchedWithUrl {
            wasLaunchedWithUrl = false
            let navController = window?.rootViewController as? UINavigationController
            let menuController = navController?.topViewController as? MenuController
            menuController?.showHistoryError = true
            menuController?.showHistoryTab()
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

    func showWelcomeController() {
        let welcomeId = WelcomeController.storyboardId
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeController = storyboard.instantiateViewController(withIdentifier: welcomeId)
        window?.rootViewController = welcomeController
    }

    func showApplicationController() {
        let appVersion = Constants.version.components(separatedBy: " ").first!
        UserDefaults.standard.set(appVersion, forKey: Constants.tutorialVersion)

        let navigationId = "rootNavigationController"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: navigationId)
        window?.rootViewController = navigationController
    }


    fileprivate func setInitialViewController() {
        let userVersion = UserDefaults.standard.string(forKey: Constants.tutorialVersion) ?? "0.0"
        let appVersion = Constants.version.components(separatedBy: " ").first!

        let userVersionArray = userVersion.components(separatedBy: ".")
        let appVersionArray = appVersion.components(separatedBy: ".")

        let userVersionMain = Int(userVersionArray[0])!
        let appVersionMain = Int(appVersionArray[0])!
        let userVersionMinor = Int(userVersionArray[1])!
        let appVersionMinor = Int(appVersionArray[1])!

        if userVersionMain < appVersionMain || userVersionMinor < appVersionMinor {
            showWelcomeController()
        } else {
            showApplicationController()
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
            if UIApplication.shared.statusBarOrientation.isLandscape {
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

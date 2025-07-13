//
//  AppDelegate.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import FirebaseCore
import AppsFlyerLib
import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // set the App ID & the DevKey
        AppsFlyerLib.shared().appleAppID = "id111168000"
        AppsFlyerLib.shared().appsFlyerDevKey = "BsNeZafNMSFczV9jhZtTxH"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
        // Debug logs
        AppsFlyerLib.shared().isDebug = true
        
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        return true
    }
    
    // For App Delegate
    func applicationDidBecomeActive(_ application: UIApplication) {
        // No Listener
        AppsFlyerLib.shared().start()
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                case .denied:
                    print("AuthorizationSatus is denied")
                case .notDetermined:
                    print("AuthorizationSatus is notDetermined")
                case .restricted:
                    print("AuthorizationSatus is restricted")
                case .authorized:
                    print("AuthorizationSatus is authorized")
                @unknown default:
                    fatalError("Invalid authorization status")
                }
            }
        }
        
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
        }
        
        print("Incoming URL: \(incomingURL)")
        // ここでDeepLinkのパースや画面遷移の通知を出す
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    // Handle Organic/Non-organic installation
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        guard let isFirstLaunch = data["is_first_launch"] as? Bool, isFirstLaunch else {
            print("🚫 Not first launch. ConversionData skipped")
            return
        }
        
        print("✅ onConversionDataSuccess data (first launch):")
        for (key, value) in data {
            print("\(key): \(value)")
        }
        
        if let deepLinkValue = data["deep_link_value"] as? String {
            print("📦 Conversion deep_link_value: \(deepLinkValue)")
            
            switch deepLinkValue.lowercased() {
            case "favorite":
                NotificationCenter.default.post(name: NSNotification.Name("navigateToFavorite"), object: nil)
            default:
                NotificationCenter.default.post(name: NSNotification.Name("navigateToSearch"), object: deepLinkValue)
            }
        } else {
            print("❌ deep_link_value not found in conversion data")
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("❌ onConversionDataFail: \(error)")
    }
}

extension AppDelegate: DeepLinkDelegate {
    func didResolveDeepLink(_ result: DeepLinkResult) {
        print("Status: \(result.status.rawValue)")
        print("Error: \(String(describing: result.error))")
        print("DeepLink: \(String(describing: result.deepLink))")
        guard let deepLink = result.deepLink else {
            print("No deep link found")
            return
        }
        
        let data = deepLink.clickEvent
        
        if let deepLinkValue = data["deep_link_value"] as? String {
            print("Deep link value: \(deepLinkValue)")
            
            switch deepLinkValue.lowercased() {
            case "favorite":
                // お気に入り画面へ遷移
                NotificationCenter.default.post(name: NSNotification.Name("navigateToFavorite"), object: nil)
                
            default:
                // その他は都市名として扱って検索
                NotificationCenter.default.post(name: NSNotification.Name("navigateToSearch"), object: deepLinkValue)
            }
        } else {
            print("No deep_link_value found")
        }
    }
}


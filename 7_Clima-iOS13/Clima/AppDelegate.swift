//
//  AppDelegate.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Firebaseの初期化
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS = apple push notification serves)
            // delegate = 移嬢(何かを渡すこと)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // Firebase Messagingのデリゲートを設定
        Messaging.messaging().delegate = self
        
        return true
        
    }
    
    // MARK: UISceneSession Lifecycle
    
    // MARK: - FCMトークンの取得
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCMトークン: \(fcmToken ?? "なし")")
    }
    
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        print("📩 プッシュ通知受信:", userInfo)
        
        // 🔹 バッジ数を更新
        updateBadgeCount(from: userInfo)
        
        // ここでデータを取得して処理
        completionHandler(.newData)
    }
    
    // バッジ数を更新する共通メソッド
    func updateBadgeCount(from userInfo: [AnyHashable: Any]) {
        print("📩 受信したプッシュ通知データ:", userInfo)
        
        if let aps = userInfo["aps"] as? [String: Any],
           let receivedBadge = aps["badge"] as? Int {
            print("📩 受信した aps:", aps)
            print("🔹 受信したバッジ数:", receivedBadge)
            
            // 保存されているバッジ数を取得
            var storedBadge = UserDefaults.standard.integer(forKey: "badge")
            print("📩 保存されているバッジ数（受信前）: \(storedBadge)")
            
            // バッジ数を更新
            storedBadge = receivedBadge
            
            // アプリのアイコンに反映
            UIApplication.shared.applicationIconBadgeNumber = storedBadge
            
            // 新しいバッジ数を保存
            UserDefaults.standard.set(storedBadge, forKey: "badge")
            print("🔹 バッジ数更新: \(storedBadge)")
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        print("🔹 Remote Notification received: \(userInfo)")
        
        // 🔹 受信したプッシュ通知のバッジ数を反映
        updateBadgeCount(from: userInfo)
        
        // 通知を表示（バッジも含む）
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        print("🔹 通知タップ: \(userInfo)")
        
        // 🔹 受信したプッシュ通知のバッジ数を反映
        updateBadgeCount(from: userInfo)
        
        completionHandler()
    }
}


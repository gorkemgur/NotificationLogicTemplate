//
//  AppDelegate.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private lazy var deeplinkParser: DeepLinkParserProtocol = {
        let deeplinkParser = DeepLinkParser()
        return deeplinkParser
    }()
    
    private lazy var deeplinkHandler: DeepLinkHandleProtocol = {
        let deeplinkHandler = DeepLinkHandleManager()
        return deeplinkHandler
    }()
    
    private lazy var notificationManager: NotificationHandlerProtocol = {
        let notificationManager = NotificationHandlerManager(deeplinkHandler: deeplinkHandler)
        return notificationManager
    }()
    
    private lazy var remoteConfigManager: FirebaseRemoteConfigManager = {
        let remoteConfigManager = FirebaseRemoteConfigManager()
        return remoteConfigManager
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if let isAppOpenedFromNotification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] {
            UserDefaults.standard.set(isAppOpenedFromNotification, forKey: "appOpenedFromNotification")
        }
        
        //MARK: - Notifications
        registerRemoteNotification()
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        notificationManager.deeplinkHandler = deeplinkHandler
        deeplinkHandler.deeplinkParser = deeplinkParser
        UNUserNotificationCenter.current().delegate = self
        
        //MARK: - Remote Config
        remoteConfigManager.delegate = self
        remoteConfigManager.checkVersionForce()
        
        window?.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        deeplinkHandler.handleDeeplink(from: userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        deeplinkHandler.handleDeeplink(from: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        deeplinkHandler.handleDeeplink(from: userInfo)
        completionHandler([.banner, .sound])
    }
}

extension AppDelegate: FirebaseRemoteConfigProtocol {
    func onVersionForce(isWillForce: Bool) {
        showForceUpdateAlert(isWillForce: isWillForce)
    }
    
    private func showForceUpdateAlert(isWillForce: Bool) {
        let alertController = UIAlertController(title: "New Version Published",
                                                message: "You have to install new version from appstore",
                                                preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { (_) in
            if let url = URL(string: "itms-apps://apps.apple.com/app/id[YOUR_APP_ID]") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            if isWillForce {
                exit(0)
            } else {
                //MARK: - REDIRECT
                /*
                 let splashViewController = SplashViewController()
                 window?.rootViewController = splashViewController
                 window?.makeKeyAndVisible()
                 */
            }
        }
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension AppDelegate {
    private func registerRemoteNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { notificationAccessGranted, error in
            if notificationAccessGranted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
    }
}


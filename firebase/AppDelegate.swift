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
        
        FirebaseApp.configure()
        
        //MARK: - Notifications
        application.registerForRemoteNotifications()
        setNotificationSettings()
        
        //MARK: - Remote Config
        setRemoteConfig()
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        return true
    }
    
    private func setNotificationSettings() {
        registerRemoteNotification()
        deeplinkHandler.deeplinkParser = deeplinkParser
        notificationManager.deeplinkHandler = deeplinkHandler
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func setRemoteConfig() {
        remoteConfigManager.delegate = self
        remoteConfigManager.fetchRemoteValues() { [weak self] (isFetched, error) in
            guard let self = self else { return }
            if isFetched {
                self.remoteConfigManager.checkVersionForce()
            } else {
                if let error = error {
                    ErrorHandler.shared.showError(error)
                }
            }
            
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        notificationManager.handleNotification(from: userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

extension AppDelegate: FirebaseRemoteConfigProtocol {
    
    func onVersionForce(versionForceType: VersionForceType) {
        switch versionForceType {
        case .onUpdate(let isWillForce):
            showForceUpdateAlert(isWillForce: isWillForce)
        case .sameVersion:
            startAppFlow()
        }
    }
    
    private func startAppFlow() {
        //MARK: - REDIRECT
        /*
         let splashViewController = SplashViewController()
         window?.rootViewController = splashViewController
         window?.makeKeyAndVisible()
         */
    }
    
    private func showForceUpdateAlert(isWillForce: Bool) {
        let message = isWillForce ? "You can not use app with this version, you have to update app" : "You should update the app there is new features"
        let alertController = UIAlertController(title: "New Version Published",
                                                message: message,
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
                self.startAppFlow()
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


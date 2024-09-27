//
//  NotificationHandlerManager.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import Foundation

final class NotificationHandlerManager {
    
    weak var deeplinkHandler: DeepLinkHandleProtocol?
    
    init(deeplinkHandler: DeepLinkHandleProtocol) {
        self.deeplinkHandler = deeplinkHandler
    }
}

extension NotificationHandlerManager: NotificationHandlerProtocol {
    func handleNotification(from userInfo: [AnyHashable : Any]) {
        if let customData = userInfo["custom"] as? [String: Any],
           let additionalData = customData["a"] as? [String: Any],
           let deepLinkUrlString = additionalData["deep_link"] as? String,
           let deepLinkUrl = URL(string: deepLinkUrlString) {
            deepLinkHandler?.handleDeepLink(with: deepLinkUrl)
        } else if let deepLink = userInfo["deepLink"] as? String, 
                  let deepLinkUrl = URL(string: deepLink) {
            deepLinkHandler?.handleDeepLink(with: deepLinkUrl)
        }
    }
}

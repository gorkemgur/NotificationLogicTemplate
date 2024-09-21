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
        guard let urlString = userInfo["deepLink"] as? String,
              let deeplinkUrl = URL(string: urlString) else {
            deeplinkHandler?.handleDeeplink(from: userInfo)
            return
        }
        handleNotification(with: deeplinkUrl)
    }
    
    private func handleNotification(with url: URL) {
        deeplinkHandler?.handleDeeplink(with: url)
    }
}

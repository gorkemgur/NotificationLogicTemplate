//
//  NotificationHandlerProtocol.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import Foundation

protocol NotificationHandlerProtocol: AnyObject {
    var deeplinkHandler: DeepLinkHandleProtocol? { get set }
    func handleNotification(from userInfo: [AnyHashable: Any])
    func handleNotification(with url: URL)
}

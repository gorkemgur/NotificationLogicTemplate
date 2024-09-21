//
//  DeepLinkHandleProtocol.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import Foundation

protocol DeepLinkHandleProtocol: AnyObject {
    var deeplinkParser: DeepLinkParserProtocol? { get set }
    func handleDeeplink(with url: URL?)
    func handleDeeplink(from userInfo: [AnyHashable: Any])
    func clearPendingDeepLink()
    var pendingDeepLink: DeepLinkModel? { get }
}

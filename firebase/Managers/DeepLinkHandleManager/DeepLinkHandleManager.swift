//
//  DeepLinkHandleManager.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import Foundation

final class DeepLinkHandleManager: DeepLinkHandleProtocol {
    
    private(set) var pendingDeepLink: DeepLinkModel?
    
    weak var deeplinkParser: DeepLinkParserProtocol?
    
    func handleDeeplink(with url: URL?) {
        guard let deepLinkUrl = url,
        let deepLinkParseResult = deeplinkParser?.parse(for: deepLinkUrl) else {
            return
        }
        switch deepLinkParseResult {
        case .success(let deepLinkModel):
            pendingDeepLink = deepLinkModel
        case .failure(let deepLinkError):
            print("Error Ocurred \(deepLinkError)")
        }
        
    }
    
    func handleDeeplink(from userInfo: [AnyHashable : Any]) {
        guard let redirectInfoId = userInfo["id"] as? String,
              let redirectionType = userInfo["type"] as? String else {
            return
        }
        pendingDeepLink = DeepLinkModel(type: DeepLinkType(rawValue: redirectionType) ?? .none, parameterId: redirectInfoId)
    }
    
    func clearPendingDeepLink() {
        pendingDeepLink = nil
    }
}

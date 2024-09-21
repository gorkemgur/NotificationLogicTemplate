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
        guard let deepLinkUrl = url else { return }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            switch deeplinkParser?.parse(for: deepLinkUrl) {
            case .success(let deepLinkModel):
                DispatchQueue.main.async {
                    self.pendingDeepLink = deepLinkModel
                }
            case .failure(let deepLinkError):
                print("Error Ocurred \(deepLinkError)")
            case .none:
                return
            }
        }
    }
    
    func handleDeeplink(from userInfo: [AnyHashable : Any]) {
        if let urlString = userInfo["deepLink"] as? String,
           let deeplinkUrl = URL(string: urlString) {
            handleDeeplink(with: deeplinkUrl)
        } else if let redirectInfoId = userInfo["id"] as? String,
                  let type = userInfo["type"] as? String {
            switch type {
            case DeepLinkType.productDetail.rawValue:
                pendingDeepLink = DeepLinkModel(type: .productDetail, url: nil, parameterId: redirectInfoId)
            case DeepLinkType.categoryDetail.rawValue:
                pendingDeepLink = DeepLinkModel(type: .categoryDetail, url: nil, parameterId: redirectInfoId)
            default:
                return
            }
        }
    }
    
    func clearPendingDeepLink() {
        pendingDeepLink = nil
    }
}

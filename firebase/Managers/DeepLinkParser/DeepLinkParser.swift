//
//  DeepLinkParser.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import Foundation

final class DeepLinkParser: DeepLinkParserProtocol {
    func parse(for url: URL?) -> Result<DeepLinkModel, DeepLinkError> {
        guard let deeplinkUrl = url, let components = URLComponents(url: deeplinkUrl, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return .failure(.invalidURL)
        }
        
        let queryItems = components.queryItems ?? []
        let parameters = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value ?? "") })
                
        var deeplinkType: DeepLinkType
        guard let parameterId = parameters["id"] else { return .failure(.invalidParameter)}
        
        switch host {
        case DeepLinkType.categoryDetail.rawValue :
            deeplinkType = .categoryDetail
        case DeepLinkType.productDetail.rawValue:
            deeplinkType = .productDetail
        default:
            return .failure(.unknownHost)
        }
        
        return .success(DeepLinkModel(type: deeplinkType, url: deeplinkUrl, parameterId: parameterId))
    }
}

enum DeepLinkError: LocalizedError {
    case invalidURL
    case invalidPath
    case invalidParameter
    case unknownHost
}

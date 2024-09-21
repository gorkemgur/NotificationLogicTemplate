//
//  DeepLinkParser.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import Foundation

enum DeepLinkHandler<T> {
    case success(T)
    case failure(DeepLinkError)
}

typealias Result<T> = DeepLinkHandler<T>

final class DeepLinkParser: DeepLinkParserProtocol {
    func parse(for url: URL?) -> Result<DeepLinkModel> {
        guard let deeplinkUrl = url, let components = URLComponents(url: deeplinkUrl, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return .failure(.invalidURL)
        }
        
        let queryItems = components.queryItems ?? []
        let parameters = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value ?? "") })
                
        var deeplinkType: DeepLinkType
        var parameterId: String
        
        switch host {
        case DeepLinkType.categoryDetail.rawValue :
            guard let id = parameters["id"] else { return .failure(.invalidParameter)}
            parameterId = id
            deeplinkType = .categoryDetail
        case DeepLinkType.productDetail.rawValue:
            guard let id = parameters["id"] else { return .failure(.invalidParameter)}
            parameterId = id
            deeplinkType = .productDetail
        default:
            return .failure(.unknownHost)
        }
        
        return .success(DeepLinkModel(type: deeplinkType, url: deeplinkUrl, parameterId: parameterId))
    }
}

enum DeepLinkError {
    case invalidURL
    case invalidPath
    case invalidParameter
    case unknownHost
}

//
//  DeepLinkParseProtocol.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import Foundation

protocol DeepLinkParserProtocol: AnyObject {
    func parse(for url: URL?) -> Result<DeepLinkModel, DeepLinkError>
}

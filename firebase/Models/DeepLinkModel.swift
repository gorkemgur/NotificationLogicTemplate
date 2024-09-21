//
//  DeepLinkModel.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import Foundation

struct DeepLinkModel {
    let type: DeepLinkType
    var url: URL?
    let parameterId: String
}

enum DeepLinkType: String {
    case productDetail = "productDetail"
    case categoryDetail = "categoryDetail"
    case none
}

//
//  DisplaySupport.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import Foundation

extension Decimal {
    var currencyLabel: String {
        formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }
}

extension Int {
    var currencyLabel: String {
        formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }
}

func vehicleImageURL(from value: String) -> URL? {
    if var components = URLComponents(string: value) {
        if components.host == "placehold.co", components.url?.pathExtension.isEmpty == true {
            components.path += ".png"
        }
        return components.url
    }

    return value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        .flatMap(URL.init(string:))
}

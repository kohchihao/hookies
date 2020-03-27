//
//  Decoder.swift
//  Hookies
//
//  Created by Jun Wei Koh on 27/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol Decoder {
    var data: [String: Any] { get }
    func value<T>(forKey key: String) throws -> T
    func optionalValue<T>(forKey key: String) -> T?
}

extension Decoder {
    func value<T>(forKey key: String) throws -> T {
        guard let value = data[key] as? T else {
            throw DataError.typeCastFailed
        }
        return value
    }

    func optionalValue<T>(forKey key: String) -> T? {
        return data[key] as? T
    }
}

enum DataError: Error {
    case typeCastFailed
}

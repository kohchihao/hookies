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

    /// Will typecast the value of the given key to the specified T type.
    /// - Parameter key: The key of the dictionary.
    func value<T>(forKey key: String) throws -> T {
        guard let value = data[key] as? T else {
            throw DataError.typeCastFailed
        }
        return value
    }

    /// Will typecast the value of the given key to the specified T type, if the value does not exist, return nil.
    /// - Parameter key: The key of the dictionary.
    func optionalValue<T>(forKey key: String) -> T? {
        return data[key] as? T
    }
}

enum DataError: Error {
    case typeCastFailed
}

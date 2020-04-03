//
//  Encoder.swift
//  Hookies
//
//  Created by Jun Wei Koh on 27/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

protocol Encoder {
    func defaultEncoding() -> [String: Any]

    /// Will serialize a strong type casted model into a dictionary.
    /// Where its properties are String and values are of type Any.
    var encoding: [String: Any] { get }
}

extension Encoder {
    /// A default serializer that will convert a model can convert all its attributes to become a key value pair.
    func defaultEncoding() -> [String: Any] {
        var data = [String: Any]()
        Mirror(reflecting: self).children.forEach { child in
            guard let property = child.label.flatMap({
                Property(label: $0, value: unwrap(any: child.value))
            }) else {
                return
            }

            data = self.encodeProperty(property: property, into: data)
        }
        return data
    }

    private func encodeProperty(property: Property,
                                into data: [String: Any]) -> [String: Any] {
        var data = data
        switch property.value {
        case is NSNull:
            break
        case let rep as DictionaryRepresentable:
            data.merge(rep.representation) { _, new in new }
        case let stringRep as StringRepresentable:
            data[property.label] = stringRep.stringValue
        case let dictionary as [String: Any]:
            data[property.label] = convertDictionary(dictionary)
        case let vector as Vector:
            data[property.label + "X"] = vector.x
            data[property.label + "Y"] = vector.y
        default:
            data[property.label] = property.value
        }
        return data
    }

    private func convertDictionary(_ dictionary: [String: Any]) -> [String: Any] {
        return dictionary.mapValues({ value in
            switch value {
            case let dict as [String: Any]:
                return convertDictionary(dict)
            case let stringRep as StringRepresentable:
                return stringRep.stringValue
            default:
                return value
            }
        })
    }

    /// Unwrap Optionals from Any.
    /// If Any is not an Optional, return its original value.
    /// If Any is Optional and is Nil, return NSNull()
    private func unwrap(any: Any) -> Any {
        let mirror = Mirror(reflecting: any)
        if mirror.displayStyle != .optional {
            return any
        }

        if mirror.children.isEmpty {
            return NSNull()
        }
        let (_, some) = mirror.children.first!
        return some
    }
}

private struct Property {
    let label: String
    let value: Any
}

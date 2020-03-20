//
//  FirestoreModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import FirebaseFirestore

/// An instance of FirestoreModel would represent a model that is covertable to a document in Firestore.
protocol FirestoreModel {
    init?(modelData: FirestoreDataModel)

    /// ID of the document in Firestore.
    var documentID: String { get }

    /// Will serialize a strong type casted model into a dictionary.
    /// Where its properties are String and values are of type Any.
    var serialized: [String: Any?] { get }
}

extension FirestoreModel {
    /// A default serializer that will convert a model can convert all its attributes to become a key value pair.
    func defaultSerializer() -> [String: Any?] {
        var data = [String: Any?]()
        Mirror(reflecting: self).children.forEach { child in
            guard let property = child.label.flatMap({
                FirebaseProperty(label: $0, value: unwrap(any: child.value))
            }) else {
                return
            }

            switch property.value {
            case is NSNull:
                break
            case let firestoreRep as FirestoreRepresentable:
                data.merge(firestoreRep.representation) { _, new in new }
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
        }
        return data
    }

    func convertDictionary(_ dictionary: [String: Any]) -> [String: Any] {
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
    func unwrap(any: Any) -> Any {
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

private struct FirebaseProperty {
    let label: String
    let value: Any
}

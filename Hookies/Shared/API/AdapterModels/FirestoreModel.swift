//
//  FirestoreModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

public struct Property {
    let label: String
    let value: Any
}

import FirebaseFirestore

protocol FirestoreModel {
    init?(modelData: FirestoreModelData)

    /// ID of the document in Firestore.
    var documentID: String { get }

    /// Will serialize a strong type casted model into a dictionary.
    /// Where its properties are String and values are of type Any.
    var serialized: [String: Any?] { get }
}

extension FirestoreModel {

    func defaultSerializer() -> [String: Any?] {
        var data = [String: Any?]()
        Mirror(reflecting: self).children.forEach { child in
            guard let property = child.label.flatMap({
                Property(label: $0, value: unwrap(any: child.value))
            }) else {
                return
            }

            switch property.value {
            case is NSNull:
                break
            case let firestoreRep as FirestoreRepresentable:
                data.merge(firestoreRep.representation) { _, new in new }
            case let vector as Vector:
                data[property.label + "X"] = vector.x
                data[property.label + "Y"] = vector.y
            default:
                data[property.label] = property.value
            }
        }
        return data
    }

    /// Determines whether Any is of type Optional
    private func isOptional(_ instance: Any) -> Bool {
        let mirror = Mirror(reflecting: instance)
        let style = mirror.displayStyle
        return style == .optional
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

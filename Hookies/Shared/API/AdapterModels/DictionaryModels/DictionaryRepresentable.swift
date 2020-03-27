//
//  DictionaryRepresentable.swift
//  Hookies
//
//  Created by Jun Wei Koh on 17/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// A protocol that will enforce a class/struct to be convertible to Firebase key value pairs representation.
protocol DictionaryRepresentable {
    var representation: [String: Any] { get }
}

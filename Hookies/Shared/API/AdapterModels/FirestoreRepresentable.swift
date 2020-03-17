//
//  FirestoreRepresentable.swift
//  Hookies
//
//  Created by Jun Wei Koh on 17/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol FirestoreRepresentable {
    var representation: [String: Any?] { get }
}

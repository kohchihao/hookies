//
//  Powerup.swift
//  Hookies
//
//  Created by Jun Wei Koh on 16/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol Powerup: Nameable, DictionaryRepresentable {
    var ownerId: String? { get }
    var isActivated: Bool { get }
}

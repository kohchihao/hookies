//
//  Nameable.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

public protocol Nameable {
    static var name: String { get }
}

extension Nameable {

    public static var name: String {
        return String(describing: self)
    }
}

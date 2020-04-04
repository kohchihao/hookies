//
//  MapType.swift
//  Hookies
//
//  Created by Marcus Koh on 15/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum MapType: String, CaseIterable {
    case DeadlockMap
    case CannotDieMap
    case FloatingLandMap
}

extension MapType: StringRepresentable {
    var stringValue: String {
        return self.rawValue
    }
}

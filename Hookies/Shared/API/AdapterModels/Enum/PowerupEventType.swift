//
//  PowerupEventType.swift
//  Hookies
//
//  Created by Jun Wei Koh on 5/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

enum PowerupEventType: String, CaseIterable, StringRepresentable {
    case activate
    case activateTrap

    var stringValue: String {
        return self.rawValue
    }
}

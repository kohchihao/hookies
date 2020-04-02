//
//  HookActionType.swift
//  Hookies
//
//  Created by Jun Wei Koh on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

enum HookActionType: String, CaseIterable, StringRepresentable {
    case activate, deactivate

    var stringValue: String {
        return self.rawValue
    }
}

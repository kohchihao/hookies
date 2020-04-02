//
//  RequestStatus.swift
//  Hookies
//
//  Created by Tan LongBin on 1/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum RequestStatus: String, CaseIterable {
    case pending
    case accepted
}

extension RequestStatus: StringRepresentable {
    var stringValue: String {
        return rawValue
    }
}

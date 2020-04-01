//
//  User+SocketData.swift
//  Hookies
//
//  Created by Jun Wei Koh on 26/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SocketIO

extension User: SocketData {
    func socketRepresentation() -> SocketData {
        [
            "uid": uid,
            "username": username
        ]
    }
}

//
//  Config.swift
//  Hookies
//
//  Created by Jun Wei Koh on 26/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct Config {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }

    static var socketURL: URL {
        if Config.isSimulator {
            return Constants.devSocketURL
        } else {
            return Constants.prodSocketURL
        }
    }
}

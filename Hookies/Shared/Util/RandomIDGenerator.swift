//
//  RandomIDGenerator.swift
//  Hookies
//
//  Created by Tan LongBin on 21/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct RandomIDGenerator {

    /// Get a random ID.
    /// - Parameter length: The length of the random ID
    static func getRandomID(length: Int) -> String {
        let alphanumeric = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        guard length > 0 else {
            return ""
        }
        var result: String = ""
        while result.count < length {
            guard let char = alphanumeric.randomElement() else {
                continue
            }
            result.append(char)
        }
        return result
    }
}

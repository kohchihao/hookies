//
//  CGPoint+Extension.swift
//  Hookies
//
//  Created by Jun Wei Koh on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {

    init(vector: Vector) {
        self.x = CGFloat(vector.x)
        self.y = CGFloat(vector.y)
    }
}

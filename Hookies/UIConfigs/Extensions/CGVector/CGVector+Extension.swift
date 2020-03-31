//
//  CGVector+Extension.swift
//  Hookies
//
//  Created by Marcus Koh on 30/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGVector {

    init(vector: Vector) {
        self.dx = CGFloat(vector.x)
        self.dy = CGFloat(vector.y)
    }
}

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
    /// Distance between 2 points.
    /// - Parameters
    ///    - point2 : The second point
    func distance(to point2: CGPoint) -> CGFloat {
        let xDiff = x - point2.x
        let yDiff = y - point2.y
        return sqrt(xDiff * xDiff + yDiff * yDiff)
    }

}

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

    /// Get the magnitude of the vector.
    var magnitude: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }

    /// Distance between 2 vectors.
    /// - Parameters
    ///    - vector2: The second vector
    func distance(to vector2: CGVector) -> CGFloat {
        let xDiff = dx - vector2.dx
        let yDiff = dy - vector2.dy
        return sqrt(xDiff * xDiff + yDiff * yDiff)
    }

    /// The dot product between 2 vectors.
    /// - Parameters
    ///    - vector2: The second vector
    func dot(with vector2: CGVector) -> CGFloat {
        return dx * vector2.dx + dy * vector2.dy
    }

    /// The unit vector.
    func unit() -> CGVector {
        guard magnitude > 0 else {
            return self
        }
        return CGVector(dx: dx / magnitude, dy: dy / magnitude)
    }

    static func + (lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

     static func - (lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }

}

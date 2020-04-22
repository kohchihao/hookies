//
//  Vector.swift
//  Hookies
//
//  Created by Jun Wei Koh on 27/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

struct Vector {
    var x: Double
    var y: Double

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    init(point: CGPoint) {
        self.x = Double(point.x)
        self.y = Double(point.y)
    }

    init(vector: CGVector) {
        self.x = Double(vector.dx)
        self.y = Double(vector.dy)
    }

    init?(vector: CGVector?) {
        guard let vector = vector else {
            return nil
        }
        self.x = Double(vector.dx)
        self.y = Double(vector.dy)
    }

    /// Get the magnitude of the vector.
    var magnitude: Double {
        return sqrt(x * x + y * y)
    }

    /// Distance between 2 vectors.
    /// - Parameters
    ///    - vector2: The second vector
    func distance(to vector2: Vector) -> Double {
        let xDiff = x - vector2.x
        let yDiff = y - vector2.y
        return sqrt(xDiff * xDiff + yDiff * yDiff)
    }

    /// The dot product between 2 vectors.
    /// - Parameters
    ///    - vector2: The second vector
    func dot(with vector2: Vector) -> Double {
        return x * vector2.x + y * vector2.y
    }

    /// The unit vector.
    func unit() -> Vector {
        guard magnitude > 0 else {
            return self
        }
        return Vector(x: x / magnitude, y: y / magnitude)
    }

    static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    func angle(from vector2: Vector) -> Double {
        let diff = self - vector2
        let angle = atan2(abs(diff.y), abs(diff.x))
        return angle
    }
}

//
//  TwoWayDictionary.swift
//  Hookies
//
//  Created by Jun Wei Koh on 18/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

struct TwoWayDictionary<S: Hashable, T: Hashable>: ExpressibleByDictionaryLiteral {
    private var st: [S: T] = [:]
    private var ts: [T: S] = [:]

    init(leftRight st: [S: T]) {
        var ts: [T:S] = [:]

        for (key, value) in st {
            ts[value] = key
        }

        self.st = st
        self.ts = ts
    }

    init(rightLeft ts: [T: S]) {
        var st: [S:T] = [:]

        for (key, value) in ts {
            st[value] = key
        }

        self.st = st
        self.ts = ts
    }

    init(dictionaryLiteral elements: (S, T)...) {
        for element in elements {
            st[element.0] = element.1
            ts[element.1] = element.0
        }
    }

    init() {}

    subscript(key: S) -> T? {
        get {
            return st[key]
        }

        set(val) {
            if let val = val {
                st[key] = val
                ts[val] = key
            }
        }
    }

    subscript(key: T) -> S? {
        get {
            return ts[key]
        }

        set(val) {
            if let val = val {
                ts[key] = val
                st[val] = key
            }
        }
    }
}

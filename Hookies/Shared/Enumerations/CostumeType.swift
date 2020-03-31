//
//  CostumeType.swift
//  Hookies
//
//  Created by Tan LongBin on 20/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

enum CostumeType: String, CaseIterable {
    case Pink_Monster
    case Owlet_Monster
    case Dude_Monster
}

extension CostumeType: StringRepresentable {
    var stringValue: String {
        return self.rawValue
    }
}

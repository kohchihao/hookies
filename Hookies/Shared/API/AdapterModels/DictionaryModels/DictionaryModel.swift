//
//  DictionaryModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 27/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

/// An instance of FirestoreModel would represent a model that is covertable to a document in Firestore.
struct DictionaryModel: Decoder {
    var data: [String: Any]
}

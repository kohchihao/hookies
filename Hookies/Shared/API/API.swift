//
//  API.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import Firebase

class API {
    static let shared = API()

    private let db: Firestore
    let user: UserStore

    private init() {
        db = Firestore.firestore()
        user = UserStore(userCollection: db.collection("users"))
    }
}

//
//  JoinGameViewModel.swift
//  Hookies
//
//  Created by Tan LongBin on 19/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

protocol JoinGameViewModelRepresentable {
    var lobby: Lobby? { get set }
}

class JoinGameViewModel: JoinGameViewModelRepresentable {
    var lobby: Lobby?
}

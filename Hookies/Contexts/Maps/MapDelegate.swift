//
//  MapDelegate.swift
//  Hookies
//
//  Created by Marcus Koh on 15/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

/// Those that implements MapDelegate will receive the selected map type.
protocol MapDelegate: AnyObject {
    func onSelected(for map: MapType)
}

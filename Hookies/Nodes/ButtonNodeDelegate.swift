//
//  ButtonNodeDelegate.swift
//  Hookies
//
//  Created by JinYing on 17/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//


protocol ButtonNodeDelegate: AnyObject {
    func didTouchBegan()
    func didTouchEnd()
}

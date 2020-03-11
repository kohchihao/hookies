//
//  UIViewController+ErrorToaster.swift
//  Hookies
//
//  Created by Jun Wei Koh on 9/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func toast(message: String) {
        let font = UIFont.boldSystemFont(ofSize: 15)
        let widthOfLabel = view.frame.width / 2
        let heightOfLabel = UILabel.height(text: message, font: font,
                                           width: view.frame.width / 2) + 20

        let toastLabel = UILabel(frame: CGRect(x: widthOfLabel / 2,
                                               y: view.frame.size.height - 100,
                                               width: widthOfLabel,
                                               height: heightOfLabel))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font

        toastLabel.textAlignment = .center
        toastLabel.alpha = 1.0
        toastLabel.numberOfLines = 4
        toastLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        toastLabel.text = message

        view.addSubview(toastLabel)
        UIView.animate(withDuration: 4, delay: 2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {_ in
            toastLabel.removeFromSuperview()
        })
    }
}

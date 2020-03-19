//
//  UIViewController+ActivityIndicator.swift
//  Hookies
//
//  Created by Jun Wei Koh on 11/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    /// Show the activity indicator on the center of the given `view`.
    func showActivityIndicator(view: UIView, loadingView: UIView) {
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        loadingView.layer.cornerRadius = 10

        let indicator = UIActivityIndicatorView()
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40, height: 40)
        indicator.center = CGPoint(x: loadingView.frame.size.width / 2,
                                   y: loadingView.frame.size.height / 2)
        indicator.hidesWhenStopped = true
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = .white

        loadingView.addSubview(indicator)
        view.addSubview(loadingView)
        view.bringSubviewToFront(loadingView)
        indicator.startAnimating()
    }

    func removeActivityIndicator(loadingView: UIView) {
        loadingView.subviews.forEach({ $0.removeFromSuperview() })
        loadingView.removeFromSuperview()
    }
}

//
//  SpreadsheetView+UIViewHierarchy.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/19/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView {
    public override var subviews: [UIView] {
        return overlayView.subviews
    }

    public override func insertSubview(_ view: UIView, at index: Int) {
        overlayView.insertSubview(view, at: index)
    }

    public override func exchangeSubview(at index1: Int, withSubviewAt index2: Int) {
        overlayView.exchangeSubview(at: index1, withSubviewAt: index2)
    }

    public override func addSubview(_ view: UIView) {
        overlayView.addSubview(view)
    }

    public override func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
        overlayView.insertSubview(view, belowSubview: siblingSubview)
    }

    public override func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
        overlayView.insertSubview(view, aboveSubview: siblingSubview)
    }

    public override func bringSubview(toFront view: UIView) {
        overlayView.bringSubview(toFront: view)
    }

    public override func sendSubview(toBack view: UIView) {
        overlayView.sendSubview(toBack: view)
    }
}

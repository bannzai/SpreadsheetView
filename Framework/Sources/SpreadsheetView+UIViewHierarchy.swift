//
//  SpreadsheetView+UIViewHierarchy.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/19/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView {
  open override func insertSubview(_ view: UIView, at index: Int) {
    overlayView.insertSubview(view, at: index)
  }
  
  open override func exchangeSubview(at index1: Int, withSubviewAt index2: Int) {
    overlayView.exchangeSubview(at: index1, withSubviewAt: index2)
  }
  
  open override func addSubview(_ view: UIView) {
    overlayView.addSubview(view)
  }
  
  open override func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
    overlayView.insertSubview(view, belowSubview: siblingSubview)
  }
  
  open override func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
    overlayView.insertSubview(view, aboveSubview: siblingSubview)
  }
  
  open override func bringSubviewToFront(_ view: UIView) {
    overlayView.bringSubviewToFront(view)
  }
  
  open override func sendSubviewToBack(_ view: UIView) {
    overlayView.sendSubviewToBack(view)
  }
}

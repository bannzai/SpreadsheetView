//
//  ScrollView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

open class ScrollViewExpandable: ScrollView {
  
  var subrowsInRowRecords = [Int: [CGFloat]]()
  
  var visibleSubCells = SubrowReusableCollection<Cell>()
  var visibleSubVerticalGridlines = SubrowReusableCollection<Gridline>()
  var visibleSubHorizontalGridlines = SubrowReusableCollection<Gridline>()
  var visibleSubBorders = SubrowReusableCollection<Border>()
  
  override open func resetReusableObjects() {
    super.resetReusableObjects()
    for cell in visibleSubCells {
      cell.removeFromSuperview()
    }
    for gridline in visibleSubVerticalGridlines {
      gridline.removeFromSuperlayer()
    }
    for gridline in visibleSubHorizontalGridlines {
      gridline.removeFromSuperlayer()
    }
    for border in visibleSubBorders {
      border.removeFromSuperview()
    }
    visibleSubCells = SubrowReusableCollection<Cell>()
    visibleSubVerticalGridlines = SubrowReusableCollection<Gridline>()
    visibleSubHorizontalGridlines = SubrowReusableCollection<Gridline>()
    visibleSubBorders = SubrowReusableCollection<Border>()
  }
}

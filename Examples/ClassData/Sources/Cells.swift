//
//  Cells.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/18/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

enum Gravity: String {
  
  case left
  case right
  
}

enum Sorting {
  
  case ascending
  case descending
  case none
  
  var icon: UIImage? {
    switch self {
    case .ascending:
      return UIImage(named: "sortUp")
    case .descending:
      return UIImage(named: "sortDown")
    default:
      return nil
    }
  }
}

class HeaderCell: Cell {
  
  var sorting: Sorting = .none {
    didSet {
      sortArrow?.image = sorting.icon
      if labelGravity == .right && sorting == .none {
        labelTrailingConstraint?.constant = 8
      }
      if labelGravity == .right && sorting != .none {
        labelTrailingConstraint?.constant = 32
      }
    }
  }
  
  var labelGravity: Gravity = .left
  
  @IBInspectable var labelGravityString: String = Gravity.left.rawValue {
    didSet {
      labelGravity = Gravity(rawValue: labelGravityString) ?? .left
    }
  }
  
  @IBOutlet weak var label: UILabel?
  
  @IBOutlet weak var sortArrow: UIImageView?
  
  @IBOutlet weak var labelTrailingConstraint: NSLayoutConstraint?
}

class DataCell: Cell {
  
  @IBOutlet weak var label: UILabel?

}

class TotalCell: Cell {
  
  @IBOutlet weak var label: UILabel?
  
}

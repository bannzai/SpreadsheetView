//
//  Cells.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/18/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class HeaderCell: Cell {
  
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

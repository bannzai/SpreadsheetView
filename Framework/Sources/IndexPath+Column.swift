//
//  IndexPath+Column.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/23/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public extension IndexPath {
  
  var column: Int {
    return section
  }
  
  init(row: Int, column: Int) {
    self.init(row: row, section: column)
  }
}

public struct SubrowIndexPath: Hashable, Comparable {
  
  var indexPath: IndexPath
  
  var subrow: Int
  
  public var row: Int {
    get {
      return indexPath.row
    }
  }
  
  public var column: Int {
    get {
      return indexPath.column
    }
  }
  
  public var hashValue: Int {
    var hash = (row ^ (row >> 32))
    hash = 31 * hash + (column ^ (column >> 32))
    hash = 31 * hash + (subrow ^ (subrow >> 32))
    return hash
  }
  
  public static func == (lhs: SubrowIndexPath, rhs: SubrowIndexPath) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column && lhs.subrow == rhs.subrow
  }
  
  public static func < (lhs: SubrowIndexPath, rhs: SubrowIndexPath) -> Bool {
    return lhs.indexPath == rhs.indexPath ? lhs.subrow < rhs.subrow : lhs.indexPath < rhs.indexPath
  }
  
}

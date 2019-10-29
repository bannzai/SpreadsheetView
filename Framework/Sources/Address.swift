//
//  Address.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public class Address: Hashable, CustomStringConvertible {
  
  let row: Int
  let column: Int
  let rowIndex: Int
  let columnIndex: Int
  
  init(row: Int = 0, column: Int = 0, rowIndex: Int = 0, columnIndex: Int = 0) {
    self.row = row
    self.column = column
    self.rowIndex = rowIndex
    self.columnIndex = columnIndex
  }
  
  public var hashValue: Int {
    return 32768 * rowIndex + columnIndex
  }
  
  public static func ==(lhs: Address, rhs: Address) -> Bool {
    return lhs.rowIndex == rhs.rowIndex && lhs.columnIndex == rhs.columnIndex
  }
  
  public var description: String {
    return "Address(row:\(row), column:\(column))"
  }
}

public class SubCellAddress: Hashable, CustomStringConvertible {
  
  let row: Int
  let column: Int
  let rowIndex: Int
  let columnIndex: Int
  let subrow: Int
  
  var _hashValue: Int?
  
  init(row: Int = 0, column: Int = 0, rowIndex: Int = 0, columnIndex: Int = 0, subrow: Int = 0) {
    self.subrow = subrow
    self.row = row
    self.column = column
    self.rowIndex = rowIndex
    self.columnIndex = columnIndex
  }
  
  public var hashValue: Int {
    guard _hashValue == nil else {
      return _hashValue!
    }
    var hash = (rowIndex ^ (rowIndex >> 32))
    hash = 31 * hash + (columnIndex ^ (columnIndex >> 32))
    hash = 31 * hash + (subrow ^ (subrow >> 32))
    _hashValue = hash
    return hash
  }
  
  public static func == (lhs: SubCellAddress, rhs: SubCellAddress) -> Bool {
    return lhs.rowIndex == rhs.rowIndex && lhs.columnIndex == rhs.columnIndex && lhs.subrow == rhs.subrow
  }
  
  public var description: String {
    return "Address(row:\(row), column:\(column), subrow:\(subrow))"
  }
  
}

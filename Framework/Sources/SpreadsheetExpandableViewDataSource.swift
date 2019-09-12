//
//  SpreadsheetViewDataSource.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/21/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

/// Implement this protocol to provide data to an `SpreadsheetView`.
public protocol SpreadsheetExpandableViewDataSource: SpreadsheetViewDataSource {
  /// Asks the number of rows in spreadsheet view.
  ///
  /// - Parameter spreadsheetView: The spreadsheet view requesting this information.
  /// - Returns: The number of subrows in `spreadsheetView`.
  func numberOfSubrows(in spreadsheetView: SpreadsheetExpandableView, for row: Int) -> Int
  /// Asks the data source for the height to use for a row in a specified location.
  ///
  /// - Parameters:
  ///   - spreadsheetView: The spreadsheet view requesting this information.
  ///   - row: The index of the row.
  /// - Returns: A nonnegative floating-point value that specifies the height (in points) that row should be.
  func spreadsheetView(_ spreadsheetView: SpreadsheetExpandableView, heightForSubrow subrow: Int, in row: Int) -> CGFloat
  /// Asks your data source object for the view that corresponds to the specified cell in the spreadsheetView.
  /// The cell that is returned must be retrieved from a call to `dequeueReusableCell(withReuseIdentifier:for:)`
  ///
  /// - Parameters:
  ///   - spreadsheetView: The spreadsheet view requesting this information.
  ///   - indexPath: The location of the cell
  /// - Returns: A cell object to be displayed at the location.
  ///   If you return nil from this method, the blank cell will be displayed by default.
  func spreadsheetView(_ spreadsheetView: SpreadsheetExpandableView, cellForItemIn subrow: Int, at indexPath: IndexPath) -> Cell?
}

extension SpreadsheetExpandableViewDataSource {
  public func spreadsheetView(_ spreadsheetView: SpreadsheetExpandableView, cellForItemIn subrow: Int, at indexPath: IndexPath) -> Cell? { return nil }
}

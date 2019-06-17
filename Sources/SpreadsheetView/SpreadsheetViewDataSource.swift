//
//  SpreadsheetViewDataSource.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/21/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

/// Implement this protocol to provide data to an `SpreadsheetView`.
public protocol SpreadsheetViewDataSource: class {
    /// Asks your data source object for the number of columns in the spreadsheet view.
    ///
    /// - Parameter spreadsheetView: The spreadsheet view requesting this information.
    /// - Returns: The number of columns in `spreadsheetView`.
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int
    /// Asks the number of rows in spreadsheet view.
    ///
    /// - Parameter spreadsheetView: The spreadsheet view requesting this information.
    /// - Returns: The number of rows in `spreadsheetView`.
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int

    /// Asks the data source for the width to use for a row in a specified location.
    ///
    /// - Parameters:
    ///   - spreadsheetView: The spreadsheet view requesting this information.
    ///   - column: The index of the column.
    /// - Returns: A nonnegative floating-point value that specifies the width (in points) that column should be.
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat
    /// Asks the data source for the height to use for a row in a specified location.
    ///
    /// - Parameters:
    ///   - spreadsheetView: The spreadsheet view requesting this information.
    ///   - row: The index of the row.
    /// - Returns: A nonnegative floating-point value that specifies the height (in points) that row should be.
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat

    /// Asks your data source object for the view that corresponds to the specified cell in the spreadsheetView.
    /// The cell that is returned must be retrieved from a call to `dequeueReusableCell(withReuseIdentifier:for:)`
    ///
    /// - Parameters:
    ///   - spreadsheetView: The spreadsheet view requesting this information.
    ///   - indexPath: The location of the cell
    /// - Returns: A cell object to be displayed at the location.
    ///   If you return nil from this method, the blank cell will be displayed by default.
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell?

    /// Asks your data source object for the array of cell ranges that indicate the range of merged cells in the spreadsheetView.
    ///
    /// - Parameter spreadsheetView: The spreadsheet view requesting this information.
    /// - Returns: An array of the cell ranges indicating the range of merged cells.
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange]
    /// Asks your data source object for the number of columns to be frozen as a fixed column header in the spreadsheetView.
    ///
    /// - Parameter spreadsheetView: The spreadsheet view requesting this information.
    /// - Returns: The number of columns to be frozen
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int
    /// Asks your data source object for the number of rows to be frozen as a fixed row header in the spreadsheetView.
    ///
    /// - Parameter spreadsheetView: The spreadsheet view requesting this information.
    /// - Returns: The number of rows to be frozen
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int
}

extension SpreadsheetViewDataSource {
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? { return nil }
    public func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] { return [] }
    public func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int { return 0 }
    public func frozenRows(in spreadsheetView: SpreadsheetView) -> Int { return 0 }
}

//
//  SpreadsheetViewDataSource.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/21/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

public protocol SpreadsheetViewDataSource: class {
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat

    // The cell that is returned must be retrieved from a call to `dequeueReusableCell(withReuseIdentifier:for:)`
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell?

    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange]
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int
}

extension SpreadsheetViewDataSource {
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? { return nil }
    public func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] { return [] }
    public func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int { return 0 }
    public func frozenRows(in spreadsheetView: SpreadsheetView) -> Int { return 0 }
}

//
//  SpreadsheetDataSource.swift
//  Calc
//
//  Created by Kishikawa Katsumi on 2017/06/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class SpreadsheetDataSource: SpreadsheetViewDataSource {
    var numberOfColumns: Int
    var numberOfRows: Int
    var frozenColumns = 1
    var frozenRows = 1
    var mergedCells = [CellRange]()
    private var columnWidths = [Int: CGFloat]()
    private var rowHeights = [Int: CGFloat]()

    let mergedCellStore = MergedCellStore()
    var data = [IndexPath: String]()

    init(numberOfColumns: Int = 255, numberOfRows: Int = 1000) {
        self.numberOfColumns = numberOfColumns + 1
        self.numberOfRows = numberOfRows + 1
    }

    func mergeCells(cellRange: CellRange) {
        for indexPath in cellRange {
            if let existingMergedCell = mergedCellStore[indexPath] {
                if existingMergedCell.contains(cellRange) {
                    continue
                }
                if cellRange.contains(existingMergedCell) {
                    unmergeCell(cellRange: existingMergedCell)
                } else {
                    fatalError("cannot merge cells in a range that overlap existing merged cells")
                }
            }
            mergedCellStore[indexPath] = cellRange
        }
        mergedCells.append(cellRange)
    }

    func unmergeCell(cellRange: CellRange) {
        for indexPath in cellRange {
            if let range = mergedCellStore[indexPath] {
                if let index = mergedCells.index(of: range) {
                    mergedCells.remove(at: index)
                }
                mergedCellStore[indexPath] = nil
            }
        }
    }

    func width(for column: Int) -> CGFloat {
        return columnWidths[column] ?? 120
    }

    func set(width: CGFloat, for column: Int) {
        columnWidths[column] = width
    }

    func height(for row: Int) -> CGFloat {
        return rowHeights[row] ?? 30
    }

    func set(height: CGFloat, for row: Int) {
        rowHeights[row] = height
    }

    // MARK: DataSource

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return numberOfColumns
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return numberOfRows
    }

    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return frozenColumns
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return frozenRows
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 {
            return 60
        }
        return width(for: column)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return height(for: row)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case (0, 0) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.text = ""
            return cell
        }
        if case (1..<numberOfColumns, 0) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.text = "\(Column(number: indexPath.column))"
            return cell
        }
        if case (0, 1..<numberOfRows) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.text = "\(indexPath.row)"
            return cell
        }
        if let text = data[indexPath] {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            cell.text = text
            return cell
        }
        return nil
    }

    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        return mergedCells
    }
}

struct Column: CustomStringConvertible {
    let number: Int
    let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

    var description: String {
        var name = ""
        var devided = number
        while devided > 0 {
            let modulo = (number - 1) % letters.count
            name += letters[modulo]
            devided = (devided - modulo) / letters.count
        }
        return String(name.characters.reversed())
    }
}

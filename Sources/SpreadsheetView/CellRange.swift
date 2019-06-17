//
//  CellRange.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

public final class CellRange {
    public let from: Location
    public let to: Location

    public let columnCount: Int
    public let rowCount: Int

    var size: CGSize?

    public convenience init(from: (row: Int, column: Int), to: (row: Int, column: Int)) {
        self.init(from: Location(row: from.row, column: from.column),
                  to: Location(row: to.row, column: to.column))
    }

    public convenience init(from: IndexPath, to: IndexPath) {
        self.init(from: Location(row: from.row, column: from.column),
                  to: Location(row: to.row, column: to.column))
    }

    init(from: Location, to: Location) {
        guard from.column <= to.column && from.row <= to.row else {
            fatalError("the value of `from` must be less than or equal to the value of `to`")
        }
        self.from = from
        self.to = to
        columnCount = to.column - from.column + 1
        rowCount = to.row - from.row + 1
    }

    public func contains(_ indexPath: IndexPath) -> Bool {
        return  from.column <= indexPath.column && to.column >= indexPath.column &&
            from.row <= indexPath.row && to.row >= indexPath.row
    }

    public func contains(_ cellRange: CellRange) -> Bool {
        return from.column <= cellRange.from.column && to.column >= cellRange.to.column &&
            from.row <= cellRange.from.row && to.row >= cellRange.to.row
    }
}

extension CellRange: Hashable {
    public var hashValue: Int {
        return from.hashValue
    }

    public static func ==(lhs: CellRange, rhs: CellRange) -> Bool {
        return lhs.from == rhs.from
    }
}

extension CellRange: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "R\(from.row)C\(from.column):R\(to.row)C\(to.column)"
    }

    public var debugDescription: String {
        return description
    }
}

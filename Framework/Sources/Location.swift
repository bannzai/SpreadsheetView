//
//  Location.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/19/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

public struct Location: Hashable {
    public let row: Int
    public let column: Int

    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(column)
    }

    init(indexPath: IndexPath) {
        self.init(row: indexPath.row, column: indexPath.column)
    }

    public static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }
}

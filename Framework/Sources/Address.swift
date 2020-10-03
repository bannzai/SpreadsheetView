//
//  Address.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import Foundation

struct Address: Hashable {
    let row: Int
    let column: Int
    let rowIndex: Int
    let columnIndex: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(rowIndex)
        hasher.combine(columnIndex)
    }

    static func ==(lhs: Address, rhs: Address) -> Bool {
        return lhs.rowIndex == rhs.rowIndex && lhs.columnIndex == rhs.columnIndex
    }
}

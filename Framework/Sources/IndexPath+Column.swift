//
//  IndexPath+Column.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/23/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public extension IndexPath {
    public var column: Int {
        return section
    }

    public init(row: Int, column: Int) {
        self.init(row: row, section: column)
    }
}

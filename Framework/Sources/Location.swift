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

    public var hashValue: Int {
        return 32768 * row + column
    }

    public static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }
}

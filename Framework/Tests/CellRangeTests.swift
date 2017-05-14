//
//  CellRangeTests.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/15/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

class CellRangeTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCreation() {
        XCTAssertEqual(CellRange(from: (2, 3), to: (5, 6)),
                       CellRange(from: Location(row: 2, column: 3), to: Location(row: 5, column: 6)))
    }

    func testContains() {
        let cellRange = CellRange(from: (2, 3), to: (6, 12))
        XCTAssertTrue(cellRange.contains(CellRange(from: (4, 5), to: (6, 8))))
        XCTAssertTrue(cellRange.contains(CellRange(from: (2, 3), to: (5, 11))))
        XCTAssertTrue(cellRange.contains(CellRange(from: (2, 3), to: (6, 12))))
        XCTAssertFalse(cellRange.contains(CellRange(from: (2, 3), to: (7, 12))))
        XCTAssertFalse(cellRange.contains(CellRange(from: (2, 3), to: (6, 13))))
        XCTAssertFalse(cellRange.contains(CellRange(from: (1, 3), to: (6, 8))))
        XCTAssertFalse(cellRange.contains(CellRange(from: (2, 2), to: (6, 8))))
        XCTAssertFalse(cellRange.contains(CellRange(from: (1, 2), to: (6, 8))))

        XCTAssertTrue(cellRange.contains(IndexPath(row: 4, column: 5)))
        XCTAssertTrue(cellRange.contains(IndexPath(row: 2, column: 3)))
        XCTAssertTrue(cellRange.contains(IndexPath(row: 2, column: 12)))
        XCTAssertTrue(cellRange.contains(IndexPath(row: 6, column: 3)))
        XCTAssertTrue(cellRange.contains(IndexPath(row: 6, column: 12)))
        XCTAssertFalse(cellRange.contains(IndexPath(row: 1, column: 5)))
        XCTAssertFalse(cellRange.contains(IndexPath(row: 4, column: 2)))
        XCTAssertFalse(cellRange.contains(IndexPath(row: 4, column: 13)))
        XCTAssertFalse(cellRange.contains(IndexPath(row: 7, column: 5)))
    }
}

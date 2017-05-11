//
//  ConfigurationTests.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/11/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

class ConfigurationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testConfiguration() {
        do {
            let configuration = CircularScrolling.Configuration.none
            XCTAssertEqual(configuration.options.direction, [])
            XCTAssertEqual(configuration.options.headerStyle, .none)
            XCTAssertEqual(configuration.options.tableStyle, [])
        }
        do {
            let configuration = CircularScrolling.Configuration.horizontally
            XCTAssertEqual(configuration.options.direction, [.horizontally])
            XCTAssertEqual(configuration.options.headerStyle, .none)
            XCTAssertEqual(configuration.options.tableStyle, [])
        }
        do {
            let configuration = CircularScrolling.Configuration.vertically
            XCTAssertEqual(configuration.options.direction, [.vertically])
            XCTAssertEqual(configuration.options.headerStyle, .none)
            XCTAssertEqual(configuration.options.tableStyle, [])
        }
        do {
            let configuration = CircularScrolling.Configuration.both
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .none)
            XCTAssertEqual(configuration.options.tableStyle, [])
        }

        do {
            let configuration = CircularScrolling.Configuration.horizontally.columnHeaderNotRepeated
            XCTAssertEqual(configuration.options.direction, [.horizontally])
            XCTAssertEqual(configuration.options.headerStyle, .none)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration.horizontally.columnHeaderNotRepeated.rowHeaderStartsFirstColumn
            XCTAssertEqual(configuration.options.direction, [.horizontally])
            XCTAssertEqual(configuration.options.headerStyle, .rowHeaderStartsFirstColumn)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration.horizontally.rowHeaderStartsFirstColumn
            XCTAssertEqual(configuration.options.direction, [.horizontally])
            XCTAssertEqual(configuration.options.headerStyle, .rowHeaderStartsFirstColumn)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated])
        }

        do {
            let configuration = CircularScrolling.Configuration.vertically.rowHeaderNotRepeated
            XCTAssertEqual(configuration.options.direction, [.vertically])
            XCTAssertEqual(configuration.options.headerStyle, .none)
            XCTAssertEqual(configuration.options.tableStyle, [.rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration.vertically.rowHeaderNotRepeated.columnHeaderStartsFirstRow
            XCTAssertEqual(configuration.options.direction, [.vertically])
            XCTAssertEqual(configuration.options.headerStyle, .columnHeaderStartsFirstRow)
            XCTAssertEqual(configuration.options.tableStyle, [.rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration.vertically.columnHeaderStartsFirstRow
            XCTAssertEqual(configuration.options.direction, [.vertically])
            XCTAssertEqual(configuration.options.headerStyle, .columnHeaderStartsFirstRow)
            XCTAssertEqual(configuration.options.tableStyle, [.rowHeaderNotRepeated])
        }

        do {
            let configuration = CircularScrolling.Configuration
                .both.columnHeaderNotRepeated
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .none)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.columnHeaderNotRepeated.rowHeaderNotRepeated
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .none)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.columnHeaderNotRepeated.rowHeaderNotRepeated.rowHeaderStartsFirstColumn
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .rowHeaderStartsFirstColumn)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.columnHeaderNotRepeated.rowHeaderNotRepeated.columnHeaderStartsFirstRow
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .columnHeaderStartsFirstRow)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.columnHeaderNotRepeated.rowHeaderStartsFirstColumn
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .rowHeaderStartsFirstColumn)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.columnHeaderNotRepeated.columnHeaderStartsFirstRow
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .columnHeaderStartsFirstRow)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.rowHeaderNotRepeated.columnHeaderNotRepeated
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .none)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.rowHeaderNotRepeated.columnHeaderNotRepeated.rowHeaderStartsFirstColumn
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .rowHeaderStartsFirstColumn)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.rowHeaderNotRepeated.columnHeaderNotRepeated.columnHeaderStartsFirstRow
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .columnHeaderStartsFirstRow)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.rowHeaderNotRepeated.rowHeaderStartsFirstColumn
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .rowHeaderStartsFirstColumn)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.rowHeaderNotRepeated.columnHeaderStartsFirstRow
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .columnHeaderStartsFirstRow)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
    }
}

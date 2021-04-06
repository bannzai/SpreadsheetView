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
                .both.rowHeaderStartsFirstColumn
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .rowHeaderStartsFirstColumn)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.columnHeaderStartsFirstRow
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .columnHeaderStartsFirstRow)
            XCTAssertEqual(configuration.options.tableStyle, [.rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.rowHeaderStartsFirstColumn.rowHeaderNotRepeated
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .rowHeaderStartsFirstColumn)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
        }
        do {
            let configuration = CircularScrolling.Configuration
                .both.columnHeaderStartsFirstRow.columnHeaderNotRepeated
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .columnHeaderStartsFirstRow)
            XCTAssertEqual(configuration.options.tableStyle, [.columnHeaderNotRepeated, .rowHeaderNotRepeated])
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
                .both.rowHeaderNotRepeated
            XCTAssertEqual(configuration.options.direction, [.both])
            XCTAssertEqual(configuration.options.headerStyle, .none)
            XCTAssertEqual(configuration.options.tableStyle, [.rowHeaderNotRepeated])
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

    func testDescription() {
        XCTAssertEqual(CircularScrolling.Configuration.none.description,
                       "(direction: [], tableStyle: [], headerStyle: .none)")

        XCTAssertEqual(CircularScrolling.Configuration.horizontally.description,
                       "(direction: [\".horizontally\"], tableStyle: [], headerStyle: .none)")
        XCTAssertEqual(CircularScrolling.Configuration.horizontally.columnHeaderNotRepeated.description,
                       "(direction: [\".horizontally\"], tableStyle: [\".columnHeaderNotRepeated\"], headerStyle: .none)")
        XCTAssertEqual(CircularScrolling.Configuration.horizontally.columnHeaderNotRepeated.rowHeaderStartsFirstColumn.description,
                       "(direction: [\".horizontally\"], tableStyle: [\".columnHeaderNotRepeated\"], headerStyle: .rowHeaderStartsFirstColumn)")

        XCTAssertEqual(CircularScrolling.Configuration.vertically.description,
                       "(direction: [\".vertically\"], tableStyle: [], headerStyle: .none)")
        XCTAssertEqual(CircularScrolling.Configuration.vertically.rowHeaderNotRepeated.description,
                       "(direction: [\".vertically\"], tableStyle: [\".rowHeaderNotRepeated\"], headerStyle: .none)")
        XCTAssertEqual(CircularScrolling.Configuration.vertically.rowHeaderNotRepeated.columnHeaderStartsFirstRow.description,
                       "(direction: [\".vertically\"], tableStyle: [\".rowHeaderNotRepeated\"], headerStyle: .columnHeaderStartsFirstRow)")

        XCTAssertEqual(CircularScrolling.Configuration.both.description,
                       "(direction: [\".vertically\", \".horizontally\"], tableStyle: [], headerStyle: .none)")
        XCTAssertEqual(CircularScrolling.Configuration.both.columnHeaderNotRepeated.description,
                       "(direction: [\".vertically\", \".horizontally\"], tableStyle: [\".columnHeaderNotRepeated\"], headerStyle: .none)")
        XCTAssertEqual(CircularScrolling.Configuration.both.columnHeaderNotRepeated.rowHeaderNotRepeated.description,
                       "(direction: [\".vertically\", \".horizontally\"], tableStyle: [\".columnHeaderNotRepeated\", \".rowHeaderNotRepeated\"], headerStyle: .none)")
        XCTAssertEqual(CircularScrolling.Configuration.both.columnHeaderNotRepeated.rowHeaderNotRepeated.columnHeaderStartsFirstRow.description,
                       "(direction: [\".vertically\", \".horizontally\"], tableStyle: [\".columnHeaderNotRepeated\", \".rowHeaderNotRepeated\"], headerStyle: .columnHeaderStartsFirstRow)")
        XCTAssertEqual(CircularScrolling.Configuration.both.columnHeaderNotRepeated.rowHeaderNotRepeated.rowHeaderStartsFirstColumn.description,
                       "(direction: [\".vertically\", \".horizontally\"], tableStyle: [\".columnHeaderNotRepeated\", \".rowHeaderNotRepeated\"], headerStyle: .rowHeaderStartsFirstColumn)")
    }

    func testScrollViewProperties() {
        let spreadsheetView = SpreadsheetView()

        XCTAssertEqual(spreadsheetView.showsVerticalScrollIndicator, true)
        XCTAssertEqual(spreadsheetView.showsVerticalScrollIndicator, spreadsheetView.overlayView.showsVerticalScrollIndicator)
        spreadsheetView.showsVerticalScrollIndicator = false
        XCTAssertEqual(spreadsheetView.showsVerticalScrollIndicator, spreadsheetView.overlayView.showsVerticalScrollIndicator)

        XCTAssertEqual(spreadsheetView.showsHorizontalScrollIndicator, true)
        XCTAssertEqual(spreadsheetView.showsHorizontalScrollIndicator, spreadsheetView.overlayView.showsHorizontalScrollIndicator)
        spreadsheetView.showsHorizontalScrollIndicator = false
        XCTAssertEqual(spreadsheetView.showsHorizontalScrollIndicator, spreadsheetView.overlayView.showsHorizontalScrollIndicator)

        XCTAssertEqual(spreadsheetView.scrollsToTop, true)
        XCTAssertEqual(spreadsheetView.scrollsToTop, spreadsheetView.tableView.scrollsToTop)
        spreadsheetView.scrollsToTop = false
        XCTAssertEqual(spreadsheetView.scrollsToTop, spreadsheetView.tableView.scrollsToTop)

        XCTAssertEqual(spreadsheetView.isDirectionalLockEnabled, false)
        XCTAssertEqual(spreadsheetView.isDirectionalLockEnabled, spreadsheetView.tableView.isDirectionalLockEnabled)
        spreadsheetView.isDirectionalLockEnabled = true
        XCTAssertEqual(spreadsheetView.isDirectionalLockEnabled, spreadsheetView.tableView.isDirectionalLockEnabled)

        XCTAssertEqual(spreadsheetView.bounces, true)
        XCTAssertEqual(spreadsheetView.bounces, spreadsheetView.tableView.bounces)
        spreadsheetView.bounces = false
        XCTAssertEqual(spreadsheetView.bounces, spreadsheetView.tableView.bounces)

        XCTAssertEqual(spreadsheetView.alwaysBounceVertical, false)
        XCTAssertEqual(spreadsheetView.alwaysBounceVertical, spreadsheetView.tableView.alwaysBounceVertical)
        spreadsheetView.alwaysBounceVertical = true
        XCTAssertEqual(spreadsheetView.alwaysBounceVertical, spreadsheetView.tableView.alwaysBounceVertical)

        XCTAssertEqual(spreadsheetView.alwaysBounceHorizontal, false)
        XCTAssertEqual(spreadsheetView.alwaysBounceHorizontal, spreadsheetView.tableView.alwaysBounceHorizontal)
        spreadsheetView.alwaysBounceHorizontal = true
        XCTAssertEqual(spreadsheetView.alwaysBounceHorizontal, spreadsheetView.tableView.alwaysBounceHorizontal)

        XCTAssertEqual(spreadsheetView.isPagingEnabled, false)
        XCTAssertEqual(spreadsheetView.isPagingEnabled, spreadsheetView.tableView.isPagingEnabled)
        spreadsheetView.isPagingEnabled = true
        XCTAssertEqual(spreadsheetView.isPagingEnabled, spreadsheetView.tableView.isPagingEnabled)

        XCTAssertEqual(spreadsheetView.isScrollEnabled, true)
        XCTAssertEqual(spreadsheetView.isScrollEnabled, spreadsheetView.tableView.isScrollEnabled)
        spreadsheetView.isScrollEnabled = false
        XCTAssertEqual(spreadsheetView.isScrollEnabled, spreadsheetView.tableView.isScrollEnabled)

        XCTAssertEqual(spreadsheetView.indicatorStyle, .default)
        XCTAssertEqual(spreadsheetView.indicatorStyle, spreadsheetView.overlayView.indicatorStyle)
        spreadsheetView.indicatorStyle = .white
        XCTAssertEqual(spreadsheetView.indicatorStyle, spreadsheetView.overlayView.indicatorStyle)
        spreadsheetView.indicatorStyle = .black
        XCTAssertEqual(spreadsheetView.indicatorStyle, spreadsheetView.overlayView.indicatorStyle)

        XCTAssertEqual(spreadsheetView.decelerationRate, UIScrollView.DecelerationRate.normal.rawValue)
        XCTAssertEqual(spreadsheetView.decelerationRate, spreadsheetView.tableView.decelerationRate.rawValue)
        spreadsheetView.decelerationRate = UIScrollView.DecelerationRate.fast.rawValue
        XCTAssertEqual(spreadsheetView.decelerationRate, spreadsheetView.tableView.decelerationRate.rawValue)
    }
}

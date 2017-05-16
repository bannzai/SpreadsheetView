//
//  CellTests.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/17/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

class CellTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testViewHierarchy() {
        let cell = Cell()
        XCTAssertNil(cell.backgroundView)
        XCTAssertNil(cell.selectedBackgroundView)
        XCTAssertEqual(cell.subviews, [cell.contentView])

        let backgroundView = UIView()
        cell.backgroundView = backgroundView
        XCTAssertEqual(cell.subviews, [backgroundView, cell.contentView])

        let selectedBackgroundView = UIView()
        cell.selectedBackgroundView = selectedBackgroundView
        XCTAssertEqual(cell.subviews, [backgroundView, selectedBackgroundView, cell.contentView])

        cell.backgroundView = nil
        XCTAssertEqual(cell.subviews, [selectedBackgroundView, cell.contentView])

        cell.backgroundView = backgroundView
        XCTAssertEqual(cell.subviews, [backgroundView, selectedBackgroundView, cell.contentView])

        cell.backgroundView = nil
        cell.selectedBackgroundView = nil
        XCTAssertEqual(cell.subviews, [cell.contentView])

        let view = UIView()
        cell.addSubview(view)
        XCTAssertEqual(cell.subviews, [cell.contentView, view])

        cell.selectedBackgroundView = selectedBackgroundView
        XCTAssertEqual(cell.subviews, [selectedBackgroundView, cell.contentView, view])

        cell.backgroundView = backgroundView
        XCTAssertEqual(cell.subviews, [backgroundView, selectedBackgroundView, cell.contentView, view])
    }

    func testHasBorder() {
        let cell = Cell()
        XCTAssertEqual(cell.borders.top, .none)
        XCTAssertEqual(cell.borders.bottom, .none)
        XCTAssertEqual(cell.borders.left, .none)
        XCTAssertEqual(cell.borders.right, .none)
        XCTAssertFalse(cell.hasBorder)

        cell.borders.top = .solid(width: 1, color: .black)
        XCTAssertTrue(cell.hasBorder)

        cell.borders.top = .none
        cell.borders.bottom = .solid(width: 1, color: .black)
        XCTAssertTrue(cell.hasBorder)

        cell.borders.bottom = .none
        cell.borders.left = .solid(width: 1, color: .black)
        XCTAssertTrue(cell.hasBorder)

        cell.borders.left = .none
        cell.borders.right = .solid(width: 1, color: .black)
        XCTAssertTrue(cell.hasBorder)

        cell.borders.right = .none
        XCTAssertFalse(cell.hasBorder)
    }
}

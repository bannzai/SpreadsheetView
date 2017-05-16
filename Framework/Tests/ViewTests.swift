//
//  ViewTests.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/30/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

class ViewTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testTableView() {
        let parameters = Parameters()
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func testColumnHeaderView() {
        let parameters = Parameters(frozenColumns: 2)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func testRowHeaderView() {
        let parameters = Parameters(frozenRows: 2)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func testColumnAndRowHeaderView() {
        let parameters = Parameters(frozenColumns: 2, frozenRows: 3)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func testHorizontalCircularScrolling() {
        let parameters = Parameters(circularScrolling: CircularScrolling.Configuration.horizontally)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func testVerticalCircularScrolling() {
        let parameters = Parameters(circularScrolling: CircularScrolling.Configuration.vertically)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func verify(view spreadsheetView: SpreadsheetView, parameters: Parameters) {
        print("parameters: \(parameters)")

        XCTAssertEqual(spreadsheetView.visibleCells.count,
                       numberOfVisibleColumns(in: spreadsheetView, parameters: parameters) * numberOfVisibleRows(in: spreadsheetView, parameters: parameters))

        for (index, visibleCell) in spreadsheetView.visibleCells
            .sorted()
            .enumerated() {
                let column = index / numberOfVisibleRows(in: spreadsheetView, parameters: parameters)
                let row = index % numberOfVisibleRows(in: spreadsheetView, parameters: parameters)
                XCTAssertEqual(visibleCell.indexPath, IndexPath(row: row, column: column))
        }
    }
}

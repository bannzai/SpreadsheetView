//
//  DataSourceTests.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/7/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

class DataSourceTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDataSourceProperties() {
        let parameters = Parameters()
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView

        XCTAssertNotNil(spreadsheetView.dataSource)
        XCTAssertEqual(spreadsheetView.numberOfColumns, parameters.numberOfColumns)
        XCTAssertEqual(spreadsheetView.numberOfRows, parameters.numberOfRows)

        XCTAssertEqual(spreadsheetView.mergedCells, parameters.mergedCells)

        XCTAssertEqual(spreadsheetView.frozenColumns, parameters.frozenColumns)
        XCTAssertEqual(spreadsheetView.frozenRows, parameters.frozenRows)
    }
}

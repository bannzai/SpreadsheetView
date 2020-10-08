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

        XCTAssertEqual(spreadsheetView.frame, spreadsheetView.window!.frame)
        XCTAssertEqual(spreadsheetView.contentInset, .zero)
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

    func testEmbedInNavigationController() {
        let parameters = Parameters()
        let viewController = defaultViewController(parameters: parameters)
        viewController.title = "Navigation Controller"
        let navigationController = UINavigationController(rootViewController: viewController)

        showViewController(viewController: navigationController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)

        XCTAssertEqual(spreadsheetView.frame, spreadsheetView.window!.frame)
        if #available(iOS 11.0, *) {
            XCTAssertEqual(spreadsheetView.adjustedContentInset.top,
                           UIApplication.shared.statusBarFrame.height + viewController.navigationController!.navigationBar.frame.height)
            XCTAssertEqual(spreadsheetView.adjustedContentInset.left, 0)
            XCTAssertEqual(spreadsheetView.adjustedContentInset.right, 0)
            XCTAssertEqual(spreadsheetView.adjustedContentInset.bottom, viewController.view.safeAreaInsets.bottom)

            XCTAssertEqual(spreadsheetView.contentInset, .zero)
        } else {
            XCTAssertEqual(spreadsheetView.contentInset.top,
                           UIApplication.shared.statusBarFrame.height + viewController.navigationController!.navigationBar.frame.height)
            XCTAssertEqual(spreadsheetView.contentInset.left, 0)
            XCTAssertEqual(spreadsheetView.contentInset.right, 0)
            XCTAssertEqual(spreadsheetView.contentInset.bottom, 0)
        }
    }

    func testEmbedInNavigationControllerInTabBarController() {
        let parameters = Parameters()
        let viewController = defaultViewController(parameters: parameters)
        viewController.title = "Navigation Controller"
        let navigationController = UINavigationController(rootViewController: viewController)
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [navigationController]

        showViewController(viewController: tabBarController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)

        XCTAssertEqual(spreadsheetView.frame, spreadsheetView.window!.frame)
        if #available(iOS 11.0, *) {
            XCTAssertEqual(spreadsheetView.adjustedContentInset.top,
                           UIApplication.shared.statusBarFrame.height + viewController.navigationController!.navigationBar.frame.height)
            XCTAssertEqual(spreadsheetView.adjustedContentInset.left, 0)
            XCTAssertEqual(spreadsheetView.adjustedContentInset.right, 0)
            XCTAssertEqual(spreadsheetView.adjustedContentInset.bottom, viewController.tabBarController!.tabBar.frame.height)

            XCTAssertEqual(spreadsheetView.contentInset, .zero)
        } else {
            XCTAssertEqual(spreadsheetView.contentInset.top,
                           UIApplication.shared.statusBarFrame.height + viewController.navigationController!.navigationBar.frame.height)
            XCTAssertEqual(spreadsheetView.contentInset.left, 0)
            XCTAssertEqual(spreadsheetView.contentInset.right, 0)
            XCTAssertEqual(spreadsheetView.contentInset.bottom, viewController.tabBarController!.tabBar.frame.height)
        }
    }

    func testEmbedInTabBarController() {
        let parameters = Parameters()
        let viewController = defaultViewController(parameters: parameters)
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [viewController]

        showViewController(viewController: tabBarController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)

        XCTAssertEqual(spreadsheetView.frame, spreadsheetView.window!.frame)
        XCTAssertEqual(spreadsheetView.contentInset, .zero)
        if #available(iOS 11.0, *) {
            XCTAssertEqual(spreadsheetView.adjustedContentInset, .zero)
        }
    }

    func testReloading() {
        let firstParameters = Parameters()
        let viewController = defaultViewController(parameters: firstParameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView

        XCTAssertEqual(spreadsheetView.contentSize, CGSize(width: calculateWidth(range: 0..<firstParameters.numberOfColumns, parameters: firstParameters),
                                                           height: calculateHeight(range: 0..<firstParameters.numberOfRows, parameters: firstParameters)))
        XCTAssertEqual(spreadsheetView.contentSize, CGSize(width: spreadsheetView.tableView.frame.origin.x + spreadsheetView.tableView.contentSize.width,
                                                           height: spreadsheetView.tableView.frame.origin.y + spreadsheetView.tableView.contentSize.height))
        verify(view: spreadsheetView, parameters: firstParameters)

        let secondParameters = Parameters(numberOfColumns: 20, numberOfRows: 30, frozenColumns: 2, frozenRows: 3, intercellSpacing: CGSize(width: 2, height: 2), gridStyle: .solid(width: 2, color: .yellow))
        applyNewParameters(secondParameters, to: viewController)

        spreadsheetView.reloadData()
        waitRunLoop()

        XCTAssertEqual(spreadsheetView.contentSize, CGSize(width: calculateWidth(range: 0..<secondParameters.numberOfColumns, parameters: secondParameters),
                                                           height: calculateHeight(range: 0..<secondParameters.numberOfRows, parameters: secondParameters)))
        XCTAssertEqual(spreadsheetView.contentSize, CGSize(width: spreadsheetView.tableView.frame.origin.x + spreadsheetView.tableView.contentSize.width,
                                                           height: spreadsheetView.tableView.frame.origin.y + spreadsheetView.tableView.contentSize.height))
        verify(view: spreadsheetView, parameters: secondParameters)

        let thirdParameters = Parameters(numberOfColumns: 3, numberOfRows: 6, frozenColumns: 0, frozenRows: 0)
        applyNewParameters(thirdParameters, to: viewController)

        spreadsheetView.reloadData()
        waitRunLoop()

        XCTAssertEqual(spreadsheetView.contentSize, CGSize(width: calculateWidth(range: 0..<thirdParameters.numberOfColumns, parameters: thirdParameters),
                                                           height: calculateHeight(range: 0..<thirdParameters.numberOfRows, parameters: thirdParameters)))
        XCTAssertEqual(spreadsheetView.contentSize, CGSize(width: spreadsheetView.tableView.frame.origin.x + spreadsheetView.tableView.contentSize.width,
                                                           height: spreadsheetView.tableView.frame.origin.y + spreadsheetView.tableView.contentSize.height))
        verify(view: spreadsheetView, parameters: thirdParameters)

        let fourthParameters = Parameters(numberOfColumns: 50, numberOfRows: 60, frozenColumns: 1, frozenRows: 1)
        applyNewParameters(fourthParameters, to: viewController)

        spreadsheetView.reloadData()
        waitRunLoop()

        XCTAssertEqual(spreadsheetView.contentSize, CGSize(width: calculateWidth(range: 0..<fourthParameters.numberOfColumns, parameters: fourthParameters),
                                                           height: calculateHeight(range: 0..<fourthParameters.numberOfRows, parameters: fourthParameters)))
        XCTAssertEqual(spreadsheetView.contentSize, CGSize(width: spreadsheetView.tableView.frame.origin.x + spreadsheetView.tableView.contentSize.width,
                                                           height: spreadsheetView.tableView.frame.origin.y + spreadsheetView.tableView.contentSize.height))
        verify(view: spreadsheetView, parameters: fourthParameters)
    }

    func applyNewParameters(_ parameters: Parameters, to viewController: SpreadsheetViewController) {
        viewController.numberOfColumns = { _ in return parameters.numberOfColumns }
        viewController.numberOfRows = { _ in return parameters.numberOfRows }
        viewController.widthForColumn = { return parameters.columns[$1] }
        viewController.heightForRow = { return parameters.rows[$1] }
        viewController.frozenColumns = { _ in return parameters.frozenColumns }
        viewController.frozenRows = { _ in return parameters.frozenRows }
        viewController.mergedCells = { _ in return parameters.mergedCells }
        viewController.cellForItemAt = { return $0.dequeueReusableCell(withReuseIdentifier: parameters.cell.reuseIdentifier, for: $1) }

        viewController.spreadsheetView.circularScrolling = parameters.circularScrolling

        viewController.spreadsheetView.intercellSpacing = parameters.intercellSpacing
        viewController.spreadsheetView.gridStyle = parameters.gridStyle
        viewController.spreadsheetView.register(parameters.cell.class, forCellWithReuseIdentifier: parameters.cell.reuseIdentifier)
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

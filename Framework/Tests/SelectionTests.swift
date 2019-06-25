//
//  SelectionTests.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/30/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

class SelectionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSelectItem() {
        let parameters = Parameters(frozenColumns: 1, frozenRows: 1)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView

        var indexPath: IndexPath

        indexPath = IndexPath(row: 0, column: 0)
        spreadsheetView.selectItem(at: indexPath, animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertNotNil(spreadsheetView.cellForItem(at: indexPath))
        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, indexPath)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 1)

        indexPath = IndexPath(row: 0, column: parameters.numberOfColumns - 1)
        spreadsheetView.selectItem(at: indexPath, animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertNotNil(spreadsheetView.cellForItem(at: indexPath))
        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, indexPath)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 1)

        indexPath = IndexPath(row: parameters.numberOfRows - 1, column: 0)
        spreadsheetView.selectItem(at: indexPath, animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertNotNil(spreadsheetView.cellForItem(at: indexPath))
        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, indexPath)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 1)

        indexPath = IndexPath(row: parameters.numberOfRows - 1, column: parameters.numberOfColumns - 1)
        spreadsheetView.selectItem(at: indexPath, animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertNotNil(spreadsheetView.cellForItem(at: indexPath))
        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, indexPath)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 1)
    }

    func testAllowsSelection() {
        let parameters = Parameters()
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        spreadsheetView.allowsSelection = false

        spreadsheetView.selectItem(at: IndexPath(row: 0, column: 0), animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertNil(spreadsheetView.indexPathForSelectedItem)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 0)

        spreadsheetView.selectItem(at: IndexPath(row: 0, column: parameters.numberOfColumns - 1), animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertNil(spreadsheetView.indexPathForSelectedItem)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 0)

        spreadsheetView.selectItem(at: IndexPath(row: parameters.numberOfRows - 1, column: 0), animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertNil(spreadsheetView.indexPathForSelectedItem)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 0)

        spreadsheetView.selectItem(at: IndexPath(row: parameters.numberOfRows - 1, column: parameters.numberOfColumns - 1), animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertNil(spreadsheetView.indexPathForSelectedItem)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 0)
    }

    func testAllowsMultipleSelection() {
        let parameters = Parameters(frozenColumns: 2, frozenRows: 2)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        spreadsheetView.allowsMultipleSelection = true

        var selectedIndexPaths = [IndexPath]()

        var indexPath = IndexPath(row: 0, column: 0)
        selectedIndexPaths.append(indexPath)

        spreadsheetView.selectItem(at: indexPath, animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, indexPath)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 1)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.first, indexPath)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.last, indexPath)

        indexPath = IndexPath(row: 0, column: parameters.numberOfColumns - 1)
        selectedIndexPaths.append(indexPath)

        spreadsheetView.selectItem(at: indexPath, animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, selectedIndexPaths.sorted().first)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, selectedIndexPaths.count)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.first, selectedIndexPaths.sorted().first)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.last, selectedIndexPaths.sorted().last)

        indexPath = IndexPath(row: parameters.numberOfRows - 1, column: 0)
        selectedIndexPaths.append(indexPath)

        spreadsheetView.selectItem(at: indexPath, animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, selectedIndexPaths.sorted().first)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, selectedIndexPaths.count)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.first, selectedIndexPaths.sorted().first)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.last, selectedIndexPaths.sorted().last)

        indexPath = IndexPath(row: parameters.numberOfRows - 1, column: parameters.numberOfColumns - 1)
        selectedIndexPaths.append(indexPath)

        spreadsheetView.selectItem(at: indexPath, animated: false, scrollPosition: [.left, .top])
        waitRunLoop()

        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, selectedIndexPaths.sorted().first)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, selectedIndexPaths.count)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.first, selectedIndexPaths.sorted().first)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.last, selectedIndexPaths.sorted().last)

        spreadsheetView.deselectItem(at: selectedIndexPaths[1], animated: false)
        selectedIndexPaths.remove(at: 1)

        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, selectedIndexPaths.sorted().first)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, selectedIndexPaths.count)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.first, selectedIndexPaths.sorted().first)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.last, selectedIndexPaths.sorted().last)

        spreadsheetView.deselectItem(at: selectedIndexPaths[0], animated: false)
        selectedIndexPaths.remove(at: 0)

        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, selectedIndexPaths.sorted().first)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, selectedIndexPaths.count)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.first, selectedIndexPaths.sorted().first)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.last, selectedIndexPaths.sorted().last)

        // deselect all items
        spreadsheetView.selectItem(at: nil, animated: false, scrollPosition: [])
        selectedIndexPaths.removeAll()

        XCTAssertNil(spreadsheetView.indexPathForSelectedItem)
        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 0)
    }

    func testTouches() {
        let parameters = Parameters()
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView

        verifyBoundaries(spreadsheetView: spreadsheetView,
                         columns: (0, parameters.numberOfColumns),
                         rows: (0, parameters.numberOfRows),
                         parameters: parameters)
    }

    func testTouchesFrozenColumns() {
        let parameters = Parameters(frozenColumns: 1)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView

        verifyBoundaries(spreadsheetView: spreadsheetView,
                         columns: (0, parameters.numberOfColumns),
                         rows: (0, parameters.numberOfRows),
                         parameters: parameters)
    }

    func testTouchesFrozenRows() {
        let parameters = Parameters(frozenRows: 2)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView

        verifyBoundaries(spreadsheetView: spreadsheetView,
                         columns: (0, parameters.numberOfColumns),
                         rows: (0, parameters.numberOfRows),
                         parameters: parameters)
    }

    func testTouchesFrozenColumnsAndRows() {
        let parameters = Parameters(frozenColumns: 1, frozenRows: 3)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView

        verifyBoundaries(spreadsheetView: spreadsheetView,
                         columns: (0, parameters.numberOfColumns),
                         rows: (0, parameters.numberOfRows),
                         parameters: parameters)
    }

    func verifyBoundaries(spreadsheetView: SpreadsheetView,
                          columns: (from: Int, to: Int),
                          rows: (from: Int, to: Int),
                          parameters: Parameters) {
        print("parameters: \(parameters)")

        var width: CGFloat = 0
        var height: CGFloat = 0
        var offsetWidth: CGFloat = 0
        var offsetHeight: CGFloat = 0
        var leftEdgeColumn = 0
        for column in columns.from..<columns.to {
            let frozenWidth = calculateWidth(range: 0..<parameters.frozenColumns, parameters: parameters) - (parameters.frozenColumns > 0 ? parameters.intercellSpacing.width : 0)
            if column > parameters.frozenColumns && width + parameters.columns[column] + parameters.intercellSpacing.width >= spreadsheetView.frame.width - frozenWidth {
                offsetWidth = calculateWidth(range: parameters.frozenColumns..<column, parameters: parameters) - parameters.intercellSpacing.width
                if parameters.columnWidth - offsetWidth - frozenWidth < spreadsheetView.frame.width - frozenWidth {
                    offsetWidth -= spreadsheetView.frame.width - (parameters.columnWidth - offsetWidth)
                }
                width = 0
                leftEdgeColumn = column
                spreadsheetView.scrollToItem(at: IndexPath(row: 0, column: column), at: [.left, .top], animated: false)
                waitRunLoop(secs: 0.0001)
            }
            width += parameters.columns[column] + parameters.intercellSpacing.width
            height = 0
            offsetHeight = 0

            for row in rows.from..<rows.to {
                let frozenHeight = calculateHeight(range: 0..<parameters.frozenRows, parameters: parameters) - (parameters.frozenRows > 0 ? parameters.intercellSpacing.height : 0)
                if row > parameters.frozenRows && height + parameters.rows[row] + parameters.intercellSpacing.height >= spreadsheetView.frame.height - frozenHeight {
                    offsetHeight = calculateHeight(range: parameters.frozenRows..<(row), parameters: parameters) - parameters.intercellSpacing.height
                    if parameters.rowHeight - offsetHeight - frozenHeight < spreadsheetView.frame.height - frozenHeight {
                        offsetHeight -= spreadsheetView.frame.height - (parameters.rowHeight - offsetHeight)
                    }
                    height = 0
                    spreadsheetView.scrollToItem(at: IndexPath(row: row, column: leftEdgeColumn), at: [.left, .top], animated: false)
                    waitRunLoop(secs: 0.0001)
                }
                height += parameters.rows[row] + parameters.intercellSpacing.height

                let indexPath = IndexPath(row: row, column: column)
                let rect = spreadsheetView.rectForItem(at: indexPath)

                func verifyTouches(at location: CGPoint, on spreadsheetView: SpreadsheetView, shouldSucceed: Bool) {
                    let touch = Touch(location: location)

                    spreadsheetView.touchesBegan(Set<UITouch>([touch]), nil)
                    waitRunLoop(secs: 0.0001)

                    spreadsheetView.touchesEnded(Set<UITouch>([touch]), nil)
                    waitRunLoop(secs: 0.0001)

                    if shouldSucceed {
                        XCTAssertEqual(spreadsheetView.indexPathForSelectedItem, indexPath)
                        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 1)
                    } else {
                        XCTAssertNil(spreadsheetView.indexPathForSelectedItem)
                        XCTAssertEqual(spreadsheetView.indexPathsForSelectedItems.count, 0)
                    }
                }

                let minX = rect.origin.x - offsetWidth
                let minY = rect.origin.y - offsetHeight
                let maxX = minX + rect.width
                let maxY = minY + rect.height
                let midX = minX + rect.width / 2
                let midY = minY + rect.height / 2

                func clearSelection() {
                    spreadsheetView.selectItem(at: nil, animated: false, scrollPosition: [])
                    waitRunLoop(secs: 0.0001)
                }

                verifyTouches(at: CGPoint(x: minX, y: minY), on: spreadsheetView, shouldSucceed: true)
                clearSelection()

                verifyTouches(at: CGPoint(x: minX, y: maxY), on: spreadsheetView, shouldSucceed: true)
                clearSelection()

                verifyTouches(at: CGPoint(x: maxX, y: minY), on: spreadsheetView, shouldSucceed: true)
                clearSelection()

                verifyTouches(at: CGPoint(x: maxX, y: maxY), on: spreadsheetView, shouldSucceed: true)
                clearSelection()

                verifyTouches(at: CGPoint(x: midX, y: midY), on: spreadsheetView, shouldSucceed: true)
                clearSelection()

                verifyTouches(at: CGPoint(x: minX - 0.01, y: minY), on: spreadsheetView, shouldSucceed: false)
                clearSelection()

                verifyTouches(at: CGPoint(x: minX, y: minY - 0.01), on: spreadsheetView, shouldSucceed: false)
                clearSelection()

                verifyTouches(at: CGPoint(x: minX - 0.01, y: maxY), on: spreadsheetView, shouldSucceed: false)
                clearSelection()

                verifyTouches(at: CGPoint(x: minX, y: maxY + 0.01), on: spreadsheetView, shouldSucceed: false)
                clearSelection()

                verifyTouches(at: CGPoint(x: maxX + 0.01, y: minY), on: spreadsheetView, shouldSucceed: false)
                clearSelection()

                verifyTouches(at: CGPoint(x: maxX, y: minY - 0.01), on: spreadsheetView, shouldSucceed: false)
                clearSelection()

                verifyTouches(at: CGPoint(x: maxX + 0.01, y: maxY), on: spreadsheetView, shouldSucceed: false)
                clearSelection()

                verifyTouches(at: CGPoint(x: maxX, y: maxY + 0.01), on: spreadsheetView, shouldSucceed: false)
                clearSelection()
            }
            spreadsheetView.scrollToItem(at: IndexPath(row: 0, column: leftEdgeColumn), at: [.left, .top], animated: false)
            waitRunLoop()
        }
    }
}

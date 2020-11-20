//
//  LayoutTests.swift
//  SpreadsheetViewTests
//
//  Created by Kishikawa Katsumi on 2017/09/15.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

class DataSource: SpreadsheetViewDataSource {
    var spreadsheetViewConfiguration: SpreadsheetViewConfiguration
    var dataSourceSnapshot: DataSourceSnapshot

    init(spreadsheetViewConfiguration: SpreadsheetViewConfiguration, dataSourceSnapshot: DataSourceSnapshot) {
        self.spreadsheetViewConfiguration = spreadsheetViewConfiguration
        self.dataSourceSnapshot = dataSourceSnapshot
    }

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return dataSourceSnapshot.columnWidthCache.count
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return dataSourceSnapshot.columnWidthCache.count
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return dataSourceSnapshot.columnWidthCache[column]
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return dataSourceSnapshot.rowHeightCache[row]
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        return nil
    }

    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        return []
    }

    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return dataSourceSnapshot.frozenColumns
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return dataSourceSnapshot.frozenRows
    }
}

class LayoutTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSimpleLayout() {
        let spreadsheetViewConfiguration = SpreadsheetViewConfiguration(intercellSpacing: CGSize(width: 4, height: 4),
                                                                        defaultGridStyle: .none,
                                                                        circularScrollingOptions: CircularScrolling.Configuration.none.options,
                                                                        circularScrollScalingFactor: (1, 1),
                                                                        blankCellReuseIdentifier: "",
                                                                        highlightedIndexPaths: [],
                                                                        selectedIndexPaths: [])
        let dataSourceSnapshot = DataSourceSnapshot(frozenColumns: 0, frozenRows: 0,
                                                    columnWidthCache: [CGFloat](repeating: 60, count: 200),
                                                    rowHeightCache: [CGFloat](repeating: 40, count: 200))
        let dataSource = DataSource(spreadsheetViewConfiguration: spreadsheetViewConfiguration, dataSourceSnapshot: dataSourceSnapshot)

        let spreadsheetView = SpreadsheetView()
        spreadsheetView.dataSource = dataSource
        let layoutProperties = SpreadsheetView.resetLayoutProperties(dataSource, spreadsheetView)
        let layoutAttribute = SpreadsheetView.layoutAttributeForTableView(spreadsheetViewConfiguration, layoutProperties)

        let scrollView = ScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 567))
        scrollView.layoutAttributes = layoutAttribute
        SpreadsheetView.initializeScrollView(scrollView: scrollView, spreadsheetViewConfiguration: spreadsheetViewConfiguration, layoutProperties: layoutProperties)

        let scrollViewConfiguration = ScrollViewConfiguration(startColumn: layoutAttribute.startColumn, startRow: layoutAttribute.startRow,
                                                              numberOfColumns: layoutAttribute.numberOfColumns, numberOfRows: layoutAttribute.numberOfRows,
                                                              columnCount: layoutAttribute.columnCount, rowCount: layoutAttribute.rowCount,
                                                              insets: layoutAttribute.insets,
                                                              columnRecords: scrollView.columnRecords, rowRecords: scrollView.rowRecords)


        do {
            let contentOffset = CGPoint(x: 0, y: 0)
            let scrollViewState = ScrollView.State(frame: scrollView.frame, contentSize: scrollView.contentSize, contentOffset: contentOffset)

            let layoutEngine = LayoutEngine(spreadsheetViewConfiguration: spreadsheetViewConfiguration,
                                            dataSourceSnapshot: dataSourceSnapshot,
                                            scrollViewConfiguration: scrollViewConfiguration,
                                            scrollViewState: scrollViewState)
            layoutEngine.layout()
            print(layoutEngine.layouter)
        }
        do {
            let contentOffset = CGPoint(x: 80, y: 0)
            let scrollViewState = ScrollView.State(frame: scrollView.frame, contentSize: scrollView.contentSize, contentOffset: contentOffset)

            let layoutEngine = LayoutEngine(spreadsheetViewConfiguration: spreadsheetViewConfiguration,
                                            dataSourceSnapshot: dataSourceSnapshot,
                                            scrollViewConfiguration: scrollViewConfiguration,
                                            scrollViewState: scrollViewState)
            layoutEngine.layout()
            print(layoutEngine.layouter)
        }
        do {
            let contentOffset = CGPoint(x: 80, y: 60)
            let scrollViewState = ScrollView.State(frame: scrollView.frame, contentSize: scrollView.contentSize, contentOffset: contentOffset)

            let layoutEngine = LayoutEngine(spreadsheetViewConfiguration: spreadsheetViewConfiguration,
                                            dataSourceSnapshot: dataSourceSnapshot,
                                            scrollViewConfiguration: scrollViewConfiguration,
                                            scrollViewState: scrollViewState)
            layoutEngine.layout()
            print(layoutEngine.layouter)
        }
    }
}

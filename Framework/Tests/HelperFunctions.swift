//
//  HelperFunctions.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/30/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

func waitRunLoop(secs: TimeInterval = 0) {
    RunLoop.main.run(until: Date(timeIntervalSinceNow: secs))
}

func defaultViewController(parameters: Parameters) -> SpreadsheetViewController {
    let viewController = SpreadsheetViewController()

    viewController.numberOfColumns = { _ in parameters.numberOfColumns }
    viewController.numberOfRows = { _ in parameters.numberOfRows }
    viewController.widthForColumn = { parameters.columns[$1] }
    viewController.heightForRow = { parameters.rows[$1] }
    viewController.frozenColumns = { _ in parameters.frozenColumns }
    viewController.frozenRows = { _ in parameters.frozenRows }
    viewController.mergedCells = { _ in parameters.mergedCells }
    viewController.cellForItemAt = { $0.dequeueReusableCell(withReuseIdentifier: parameters.cell.reuseIdentifier, for: $1) }

    viewController.spreadsheetView.circularScrolling = parameters.circularScrolling

    viewController.spreadsheetView.intercellSpacing = parameters.intercellSpacing
    viewController.spreadsheetView.gridStyle = parameters.gridStyle
    viewController.spreadsheetView.register(parameters.cell.class, forCellWithReuseIdentifier: parameters.cell.reuseIdentifier)

    return viewController
}

func showViewController(viewController: UIViewController) {
    let window = UIWindow()
    window.backgroundColor = .white
    window.rootViewController = viewController
    window.makeKeyAndVisible()
}

func numberOfVisibleColumns(in view: SpreadsheetView, contentOffset: CGPoint = .zero, parameters: Parameters) -> Int {
    var columnCount = 0
    var width: CGFloat = 0
    let frame = CGRect(origin: view.frame.origin,
                       size: CGSize(width: view.frame.width - (view.contentInset.left + view.contentInset.right),
                                    height: view.frame.height - (view.contentInset.top + view.contentInset.bottom)))
    for columnWidth in parameters.columns {
        width += columnWidth + parameters.intercellSpacing.width
        if width > contentOffset.x {
            columnCount += 1
        }
        if width + parameters.intercellSpacing.width > contentOffset.x + frame.width {
            break
        }
    }
    return columnCount
}

func numberOfVisibleRows(in view: SpreadsheetView, contentOffset: CGPoint = .zero, parameters: Parameters) -> Int {
    var rowCount = 0
    var height: CGFloat = 0
    let frame = CGRect(origin: view.frame.origin,
                       size: CGSize(width: view.frame.width - (view.contentInset.left + view.contentInset.right),
                                    height: view.frame.height - (view.contentInset.top + view.contentInset.bottom)))
    for rowHeight in parameters.rows {
        height += rowHeight + parameters.intercellSpacing.height
        if height > contentOffset.y {
            rowCount += 1
        }
        if height + parameters.intercellSpacing.height > contentOffset.y + frame.height {
            break
        }
    }
    return rowCount
}

func calculateWidth(range: CountableRange<Int>, parameters: Parameters) -> CGFloat {
    return range.map { parameters.columns[$0] }.reduce(0) { $0 + $1 + parameters.intercellSpacing.width }
}

func calculateHeight(range: CountableRange<Int>, parameters: Parameters) -> CGFloat {
    return range.map { parameters.rows[$0] }.reduce(0) { $0 + $1 + parameters.intercellSpacing.height }
}


func randomArray<T>(seeds: [T], count: Int) -> [T] {
    return (0..<count).map { _ in seeds[Int(arc4random_uniform(UInt32(seeds.count)))] }
}

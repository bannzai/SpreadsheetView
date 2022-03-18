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

    return viewController
}

func showViewController(viewController: UIViewController) {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = .white
    window.rootViewController = viewController
    window.makeKeyAndVisible()
}

func numberOfVisibleColumns(in view: SpreadsheetView, contentOffset: CGPoint = .zero, parameters: Parameters) -> Int {
    let contentInset: UIEdgeInsets
    if #available(iOS 11.0, *) {
        contentInset = view.adjustedContentInset
    } else {
        contentInset = view.contentInset
    }
    let horizontalInset = contentInset.left + contentInset.right
    let verticalInset = contentInset.top + contentInset.bottom

    var columnCount = 0
    var width: CGFloat = 0
    let frame = CGRect(origin: view.frame.origin,
                       size: CGSize(width: view.frame.width - horizontalInset, height: view.frame.height - verticalInset))
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
    let contentInset: UIEdgeInsets
    if #available(iOS 11.0, *) {
        contentInset = view.adjustedContentInset
    } else {
        contentInset = view.contentInset
    }
    let horizontalInset = contentInset.left + contentInset.right
    let verticalInset = contentInset.top + contentInset.bottom

    var rowCount = 0
    var height: CGFloat = 0
    let frame = CGRect(origin: view.frame.origin,
                       size: CGSize(width: view.frame.width - horizontalInset, height: view.frame.height - verticalInset))
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
    return range.map { return parameters.columns[$0] }.reduce(0) { $0 + $1 + parameters.intercellSpacing.width } + (range.count > 0 ? parameters.intercellSpacing.width : 0)
}

func calculateHeight(range: CountableRange<Int>, parameters: Parameters) -> CGFloat {
    return range.map { return parameters.rows[$0] }.reduce(0) { $0 + $1 + parameters.intercellSpacing.height } + (range.count > 0 ? parameters.intercellSpacing.height : 0)
}

func randomArray<T>(seeds: [T], count: Int) -> [T] {
    return (0..<count).map { _ in return seeds[Int(arc4random_uniform(UInt32(seeds.count)))] }
}

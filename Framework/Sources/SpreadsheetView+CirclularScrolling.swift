//
//  SpreadsheetView+CirclularScrolling.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/1/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView {
    func scrollToHorizontalCenter() {
        rowHeaderView.contentOffset.x = centerOffset.x
        tableView.contentOffset.x = centerOffset.x
        centerSubviewsHorizontally(offset: centerOffset.x)
    }

    func scrollToVerticalCenter() {
        columnHeaderView.contentOffset.y = centerOffset.y
        tableView.contentOffset.y = centerOffset.y
        centerSubviewsVertically(offset: centerOffset.y)
    }

    func recenterHorizontallyIfNecessary() {
        let currentOffset = tableView.contentOffset
        let distance = currentOffset.x - centerOffset.x

        let threshold = tableView.contentSize.width / 4
        let diff = (centerOffset.x - threshold) * (distance > 0 ? -1 : 1)

        if fabs(distance) > threshold {
            let offset = centerOffset.x + diff
            rowHeaderView.contentOffset.x = offset
            tableView.contentOffset.x = offset
            centerSubviewsHorizontally(offset: offset - currentOffset.x)
        }
    }

    func centerSubviewsHorizontally(offset: CGFloat) {
        for cell in rowHeaderView.visibleCells {
            cell.center.x += offset
        }
        for cell in tableView.visibleCells {
            cell.center.x += offset
        }
        for border in rowHeaderView.visibleBorders {
            border.center.x += offset
        }
        for border in tableView.visibleBorders {
            border.center.x += offset
        }

        for gridline in rowHeaderView.visibleHorizontalGridlines {
            gridline.position.x += offset
        }
        for gridline in rowHeaderView.visibleVerticalGridlines {
            gridline.position.x += offset
        }
        for gridline in tableView.visibleHorizontalGridlines{
            gridline.position.x += offset
        }
        for gridline in tableView.visibleVerticalGridlines {
            gridline.position.x += offset
        }
    }

    func recenterVerticallyIfNecessary() {
        let currentOffset = tableView.contentOffset
        let distance = currentOffset.y - centerOffset.y

        let threshold = tableView.contentSize.height / 4
        let diff = (centerOffset.y - threshold) * (distance > 0 ? -1 : 1)

        if fabs(distance) > threshold {
            let offset = centerOffset.y + diff
            columnHeaderView.contentOffset.y = offset
            tableView.contentOffset.y = offset
            centerSubviewsVertically(offset: offset - currentOffset.y)
        }
    }

    func centerSubviewsVertically(offset: CGFloat) {
        for cell in columnHeaderView.visibleCells {
            cell.center.y += offset
        }
        for cell in tableView.visibleCells {
            cell.center.y += offset
        }
        for border in rowHeaderView.visibleBorders {
            border.center.y += offset
        }
        for border in tableView.visibleBorders {
            border.center.y += offset
        }

        for gridline in columnHeaderView.visibleHorizontalGridlines {
            gridline.position.y += offset
        }
        for gridline in columnHeaderView.visibleVerticalGridlines {
            gridline.position.y += offset
        }
        for gridline in tableView.visibleHorizontalGridlines {
            gridline.position.y += offset
        }
        for gridline in tableView.visibleVerticalGridlines {
            gridline.position.y += offset
        }
    }

    func determineCircularScrollScalingFactor() -> (horizontal: Int, vertical: Int) {
        return (determineHorizontalCircularScrollScalingFactor(), determineVerticalCircularScrollScalingFactor())
    }

    func determineHorizontalCircularScrollScalingFactor() -> Int {
        guard circularScrollingOptions.direction.contains(.horizontally) else {
            return 1
        }
        let tableContentWidth = layoutProperties.columnWidth - layoutProperties.frozenColumnWidth
        let tableWidth = frame.width - layoutProperties.frozenColumnWidth
        var scalingFactor = 3
        while tableContentWidth > 0 && Int(tableContentWidth) * scalingFactor < Int(tableWidth) * 3 {
            scalingFactor += 3
        }
        return scalingFactor
    }

    func determineVerticalCircularScrollScalingFactor() -> Int {
        guard circularScrollingOptions.direction.contains(.vertically) else {
            return 1
        }
        let tableContentHeight = layoutProperties.rowHeight - layoutProperties.frozenRowHeight
        let tableHeight = frame.height - layoutProperties.frozenRowHeight
        var scalingFactor = 3
        while tableContentHeight > 0 && Int(tableContentHeight) * scalingFactor < Int(tableHeight) * 3 {
            scalingFactor += 3
        }
        return scalingFactor
    }

    func calculateCenterOffset() -> CGPoint {
        var centerOffset = CGPoint.zero
        if circularScrollingOptions.direction.contains(.horizontally) {
            for column in 0..<layoutProperties.numberOfColumns {
                centerOffset.x += layoutProperties.columnWidthCache[column % numberOfColumns] + intercellSpacing.width
            }
            if circularScrollingOptions.tableStyle.contains(.columnHeaderNotRepeated) {
                for column in 0..<layoutProperties.frozenColumns {
                    centerOffset.x -= layoutProperties.columnWidthCache[column]
                }
                centerOffset.x -=  intercellSpacing.width * CGFloat(layoutProperties.frozenColumns)
            }
            centerOffset.x *= CGFloat(circularScrollScalingFactor.horizontal / 3)
        }
        if circularScrollingOptions.direction.contains(.vertically) {
            for row in 0..<layoutProperties.numberOfRows {
                centerOffset.y += layoutProperties.rowHeightCache[row % numberOfRows] + intercellSpacing.height
            }
            if circularScrollingOptions.tableStyle.contains(.rowHeaderNotRepeated) {
                for column in 0..<layoutProperties.frozenRows {
                    centerOffset.y -= layoutProperties.rowHeightCache[column]
                }
                centerOffset.y -=  intercellSpacing.height * CGFloat(layoutProperties.frozenRows)
            }
        }
        return centerOffset
    }
}

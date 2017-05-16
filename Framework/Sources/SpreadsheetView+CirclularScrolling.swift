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

        for cell in rowHeaderView.visibleCells.values {
            cell.center.x += centerOffset.x
        }
        for cell in tableView.visibleCells.values {
            cell.center.x += centerOffset.x
        }

        for grid in rowHeaderView.visibleHorizontalGridlines.values {
            grid.position.x += centerOffset.x
        }
        for grid in rowHeaderView.visibleVerticalGridlines.values {
            grid.position.x += centerOffset.x
        }
        for grid in tableView.visibleHorizontalGridlines.values {
            grid.position.x += centerOffset.x
        }
        for grid in tableView.visibleVerticalGridlines.values {
            grid.position.x += centerOffset.x
        }
    }

    func scrollToVerticalCenter() {
        columnHeaderView.contentOffset.y = centerOffset.y
        tableView.contentOffset.y = centerOffset.y

        for cell in columnHeaderView.visibleCells.values {
            cell.center.y += centerOffset.y
        }
        for cell in tableView.visibleCells.values {
            cell.center.y += centerOffset.y
        }

        for grid in columnHeaderView.visibleHorizontalGridlines.values {
            grid.position.y += centerOffset.y
        }
        for grid in columnHeaderView.visibleVerticalGridlines.values {
            grid.position.y += centerOffset.y
        }
        for grid in tableView.visibleHorizontalGridlines.values {
            grid.position.y += centerOffset.y
        }
        for grid in tableView.visibleVerticalGridlines.values {
            grid.position.y += centerOffset.y
        }
    }

    func recenterHorizontallyIfNecessary() {
        let currentOffset = tableView.contentOffset
        let distance = currentOffset.x - centerOffset.x

        let threshold = tableView.contentSize.width / 4
        let diff = (centerOffset.x - threshold) * (distance > 0 ? -1 : 1)

        if fabs(distance) > threshold {
            let viewOffset = centerOffset.x + diff
            rowHeaderView.contentOffset.x = viewOffset
            tableView.contentOffset.x = viewOffset

            let cellOffset = viewOffset - currentOffset.x
            for cell in rowHeaderView.visibleCells.values {
                cell.center.x += cellOffset
            }
            for cell in tableView.visibleCells.values {
                cell.center.x += cellOffset
            }

            for grid in rowHeaderView.visibleHorizontalGridlines.values {
                grid.position.x += cellOffset
            }
            for grid in rowHeaderView.visibleVerticalGridlines.values {
                grid.position.x += cellOffset
            }
            for grid in tableView.visibleHorizontalGridlines.values {
                grid.position.x += cellOffset
            }
            for grid in tableView.visibleVerticalGridlines.values {
                grid.position.x += cellOffset
            }
        }
    }

    func recenterVerticallyIfNecessary() {
        let currentOffset = tableView.contentOffset
        let distance = currentOffset.y - centerOffset.y

        let threshold = tableView.contentSize.height / 4
        let diff = (centerOffset.y - threshold) * (distance > 0 ? -1 : 1)

        if fabs(distance) > threshold {
            let viewOffset = centerOffset.y + diff
            columnHeaderView.contentOffset.y = viewOffset
            tableView.contentOffset.y = viewOffset

            let cellOffset = viewOffset - currentOffset.y
            for cell in columnHeaderView.visibleCells.values {
                cell.center.y += cellOffset
            }
            for cell in tableView.visibleCells.values {
                cell.center.y += cellOffset
            }

            for grid in columnHeaderView.visibleHorizontalGridlines.values {
                grid.position.y += cellOffset
            }
            for grid in columnHeaderView.visibleVerticalGridlines.values {
                grid.position.y += cellOffset
            }
            for grid in tableView.visibleHorizontalGridlines.values {
                grid.position.y += cellOffset
            }
            for grid in tableView.visibleVerticalGridlines.values {
                grid.position.y += cellOffset
            }
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

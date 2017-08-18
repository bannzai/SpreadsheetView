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
        rowHeaderView.state.contentOffset.x = centerOffset.x
        tableView.state.contentOffset.x = centerOffset.x
    }

    func scrollToVerticalCenter() {
        columnHeaderView.state.contentOffset.y = centerOffset.y
        tableView.state.contentOffset.y = centerOffset.y
    }

    func recenterHorizontallyIfNecessary() {
        let currentOffset = tableView.state.contentOffset
        let distance = currentOffset.x - centerOffset.x
        let threshold = tableView.state.contentSize.width / 4
        if fabs(distance) > threshold {
            if distance > 0 {
                rowHeaderView.state.contentOffset.x = distance
                tableView.state.contentOffset.x = distance
            } else {
                let offset = centerOffset.x + (centerOffset.x - threshold)
                rowHeaderView.state.contentOffset.x = offset
                tableView.state.contentOffset.x = offset
            }
        }
    }

    func recenterVerticallyIfNecessary() {
        let currentOffset = tableView.state.contentOffset
        let distance = currentOffset.y - centerOffset.y
        let threshold = tableView.state.contentSize.height / 4
        if fabs(distance) > threshold {
            if distance > 0 {
                columnHeaderView.state.contentOffset.y = distance
                tableView.state.contentOffset.y = distance
            } else {
                let offset = centerOffset.y + (centerOffset.y - threshold)
                columnHeaderView.state.contentOffset.y = offset
                tableView.state.contentOffset.y = offset
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

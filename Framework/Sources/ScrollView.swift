//
//  ScrollView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

final class ScrollView: UIScrollView, UIGestureRecognizerDelegate {
    var columnRecords = [CGFloat]()
    var rowRecords = [CGFloat]()

    var visibleCells = [Address: Cell]()
    var visibleCellAddresses = Set<Address>()

    var visibleVerticalGrids = [Address: Grid]()
    var visibleVerticalGridAddresses = Set<Address>()
    var reusableVerticalGrids = Set<Grid>()

    var visibleHorizontalGrids = [Address: Grid]()
    var visibleHorizontalGridAddresses = Set<Address>()
    var reusableHorizontalGrids = Set<Grid>()

    var visibleBorders = [Address: Border]()
    var visibleBorderAddresses = Set<Address>()
    var reusableBorders = Set<Border>()

    typealias TouchHandler = (_ touches: Set<UITouch>, _ event: UIEvent?) -> Void
    var touchesBegan: TouchHandler?
    var touchesEnded: TouchHandler?
    var touchesCancelled: TouchHandler?

    var layoutAttributes = LayoutAttributes(startColumn: 0, startRow: 0, numberOfColumns: 0, numberOfRows: 0, columnCount: 0, rowCount: 0, insets: CGPoint.zero)

    var hasDisplayedContent: Bool {
        return columnRecords.count > 0 || rowRecords.count > 0
    }

    func dequeueReusableVerticalGrid() -> Grid {
        if let grid = reusableVerticalGrids.first {
            reusableVerticalGrids.remove(grid)
            return grid
        }
        return Grid()
    }

    func dequeueReusableHorizontalGrid() -> Grid {
        if let grid = reusableHorizontalGrids.first {
            reusableHorizontalGrids.remove(grid)
            return grid
        }
        return Grid()
    }

    func dequeueReusableBorder() -> Border {
        if let border = reusableBorders.first {
            reusableBorders.remove(border)
            return border
        }
        return Border()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer
    }

    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        return hasDisplayedContent
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesBegan?(touches, event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesEnded?(touches, event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesCancelled?(touches, event)
    }
}

//
//  ScrollView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

public final class ScrollView: UIScrollView, UIGestureRecognizerDelegate {
    var columnRecords = [CGFloat]()
    var rowRecords = [CGFloat]()

    var visibleCells = [Address: Cell]()
    var visibleCellAddresses = Set<Address>()

    var visibleVerticalGridlines = [Address: Gridline]()
    var visibleVerticalGridAddresses = Set<Address>()
    var reusableVerticalGridlines = Set<Gridline>()

    var visibleHorizontalGridlines = [Address: Gridline]()
    var visibleHorizontalGridAddresses = Set<Address>()
    var reusableHorizontalGridlines = Set<Gridline>()

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

    func dequeueReusableVerticalGrid() -> Gridline {
        if let grid = reusableVerticalGridlines.first {
            reusableVerticalGridlines.remove(grid)
            return grid
        }
        return Gridline()
    }

    func dequeueReusableHorizontalGrid() -> Gridline {
        if let grid = reusableHorizontalGridlines.first {
            reusableHorizontalGridlines.remove(grid)
            return grid
        }
        return Gridline()
    }

    func dequeueReusableBorder() -> Border {
        if let border = reusableBorders.first {
            reusableBorders.remove(border)
            return border
        }
        return Border()
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer
    }

    override public func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        return hasDisplayedContent
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesBegan?(touches, event)
        next?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesMoved(touches, with: event)
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesEnded?(touches, event)
        next?.touchesEnded(touches, with: event)
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesCancelled?(touches, event)
        next?.touchesCancelled(touches, with: event)
    }
}

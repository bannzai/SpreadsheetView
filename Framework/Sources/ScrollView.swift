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

    var visibleCells = ReusableCollection<Cell>()
    let visibleVerticalGridlines = ReusableCollection<Gridline>()
    let visibleHorizontalGridlines = ReusableCollection<Gridline>()
    let visibleBorders = ReusableCollection<Border>()

    typealias TouchHandler = (_ touches: Set<UITouch>, _ event: UIEvent?) -> Void
    var touchesBegan: TouchHandler?
    var touchesEnded: TouchHandler?
    var touchesCancelled: TouchHandler?

    var layoutAttributes = LayoutAttributes(startColumn: 0, startRow: 0, numberOfColumns: 0, numberOfRows: 0, columnCount: 0, rowCount: 0, insets: CGPoint.zero)

    var hasDisplayedContent: Bool {
        return columnRecords.count > 0 || rowRecords.count > 0
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
        next?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesEnded?(touches, event)
        next?.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesCancelled?(touches, event)
        next?.touchesCancelled(touches, with: event)
    }
}

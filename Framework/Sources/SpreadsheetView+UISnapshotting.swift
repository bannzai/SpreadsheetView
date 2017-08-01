//
//  SpreadsheetView+UISnapshotting.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 2017/06/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension CGRect {
    func offset(by delta: CGPoint) -> CGRect {
        return offsetBy(dx: delta.x, dy: delta.y)
    }
}

extension CGPoint {
    prefix static func -(point: CGPoint) -> CGPoint {
        return CGPoint(x: -point.x, y: -point.y)
    }
}

extension SpreadsheetView {
    public override func resizableSnapshotView(from rect: CGRect, afterScreenUpdates afterUpdates: Bool, withCapInsets capInsets: UIEdgeInsets) -> UIView? {
        if cornerView.frame.intersects(cornerView.convert(rect, to: self)) {
            return cornerView.resizableSnapshotView(from: rect.offset(by: -cornerView.frame.origin),
                                                    afterScreenUpdates: afterUpdates,
                                                    withCapInsets: capInsets)
        }
        if columnHeaderView.frame.intersects(columnHeaderView.convert(rect, to: self)) {
            return columnHeaderView.resizableSnapshotView(from: rect.offset(by: -columnHeaderView.frame.origin),
                                                          afterScreenUpdates: afterUpdates,
                                                          withCapInsets: capInsets)
        }
        if rowHeaderView.frame.intersects(rowHeaderView.convert(rect, to: self)) {
            return rowHeaderView.resizableSnapshotView(from: rect.offset(by: -rowHeaderView.frame.origin),
                                                       afterScreenUpdates: afterUpdates,
                                                       withCapInsets: capInsets)
        }
        if tableView.frame.intersects(tableView.convert(rect, to: self)) {
            return tableView.resizableSnapshotView(from: rect.offset(by: -tableView.frame.origin),
                                                   afterScreenUpdates: afterUpdates,
                                                   withCapInsets: capInsets)
        }
        return super.resizableSnapshotView(from: rect, afterScreenUpdates: afterUpdates, withCapInsets: capInsets)
    }
}

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

extension ScrollView     {
    @nonobjc func _resizableSnapshotView(from rect : CGRect, afterUpdates: Bool, with insets: UIEdgeInsets) -> UIView? {
        if frame.intersects(convert(rect, to: self)) {
            return resizableSnapshotView(from:rect.offset(by:-frame.origin),
                                        afterScreenUpdates:afterUpdates,
                                        withCapInsets:insets)
        }
        return nil
    }
}

extension SpreadsheetView {
    public override func resizableSnapshotView(from rect: CGRect, afterScreenUpdates afterUpdates: Bool, withCapInsets capInsets: UIEdgeInsets) -> UIView? {
        return cornerView._resizableSnapshotView(from: rect, afterUpdates: afterUpdates, with: capInsets) ??
            columnHeaderView._resizableSnapshotView(from: rect, afterUpdates: afterUpdates, with: capInsets) ??
            rowHeaderView._resizableSnapshotView(from: rect, afterUpdates: afterUpdates, with: capInsets) ??
            tableView._resizableSnapshotView(from: rect, afterUpdates: afterUpdates, with: capInsets) ??
            super.resizableSnapshotView(from: rect, afterScreenUpdates: afterUpdates, withCapInsets: capInsets)
    }
}

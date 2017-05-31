//
//  SpreadsheetView+UISnapshotting.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 2017/06/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView {
    public override func resizableSnapshotView(from rect: CGRect, afterScreenUpdates afterUpdates: Bool, withCapInsets capInsets: UIEdgeInsets) -> UIView? {
        var targetRect = self.convert(rect, to: cornerView)
        if cornerView.bounds.intersects(targetRect) {
            return cornerView.resizableSnapshotView(from: targetRect, afterScreenUpdates: afterUpdates, withCapInsets: capInsets)
        }
        targetRect = self.convert(rect, to: columnHeaderView)
        if columnHeaderView.bounds.intersects(targetRect) {
            return columnHeaderView.resizableSnapshotView(from: targetRect, afterScreenUpdates: afterUpdates, withCapInsets: capInsets)
        }
        targetRect = self.convert(rect, to: rowHeaderView)
        if rowHeaderView.bounds.intersects(targetRect) {
            return rowHeaderView.resizableSnapshotView(from: targetRect, afterScreenUpdates: afterUpdates, withCapInsets: capInsets)
        }
        targetRect = self.convert(rect, to: tableView)
        if tableView.bounds.intersects(targetRect) {
            return tableView.resizableSnapshotView(from: targetRect, afterScreenUpdates: afterUpdates, withCapInsets: capInsets)
        }
        return super.resizableSnapshotView(from: rect, afterScreenUpdates: afterUpdates, withCapInsets: capInsets)
    }
}

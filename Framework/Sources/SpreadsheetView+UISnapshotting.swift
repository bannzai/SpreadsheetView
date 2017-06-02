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
        if cornerView.frame.intersects(cornerView.convert(rect, to: self)) {
            return cornerView.resizableSnapshotView(from: rect.offsetBy(dx: -cornerView.frame.origin.x, dy: -cornerView.frame.origin.y),
                                                    afterScreenUpdates: afterUpdates,
                                                    withCapInsets: capInsets)
        }
        if columnHeaderView.frame.intersects(columnHeaderView.convert(rect, to: self)) {
            return columnHeaderView.resizableSnapshotView(from: rect.offsetBy(dx: -columnHeaderView.frame.origin.x, dy: -columnHeaderView.frame.origin.y),
                                                          afterScreenUpdates: afterUpdates,
                                                          withCapInsets: capInsets)
        }
        if rowHeaderView.frame.intersects(rowHeaderView.convert(rect, to: self)) {
            return rowHeaderView.resizableSnapshotView(from: rect.offsetBy(dx: -rowHeaderView.frame.origin.x, dy: -rowHeaderView.frame.origin.y),
                                                       afterScreenUpdates: afterUpdates,
                                                       withCapInsets: capInsets)
        }
        if tableView.frame.intersects(tableView.convert(rect, to: self)) {
            return tableView.resizableSnapshotView(from: rect.offsetBy(dx: -tableView.frame.origin.x, dy: -tableView.frame.origin.y),
                                                   afterScreenUpdates: afterUpdates,
                                                   withCapInsets: capInsets)
        }
        return super.resizableSnapshotView(from: rect, afterScreenUpdates: afterUpdates, withCapInsets: capInsets)
    }
}

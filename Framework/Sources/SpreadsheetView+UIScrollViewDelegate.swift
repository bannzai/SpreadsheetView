//
//  SpreadsheetView+UIScrollViewDelegate.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/1/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        rowHeaderView.delegate = nil
        columnHeaderView.delegate = nil
        tableView.delegate = nil
        defer {
            rowHeaderView.delegate = self
            columnHeaderView.delegate = self
            tableView.delegate = self
        }

        if tableView.contentOffset.x < 0 && !stickyColumnHeader {
            let offset = tableView.contentOffset.x * -1
            cornerView.frame.origin.x = offset
            columnHeaderView.frame.origin.x = offset
        } else {
            cornerView.frame.origin.x = 0
            columnHeaderView.frame.origin.x = 0
        }
        if tableView.contentOffset.y < 0 && !stickyRowHeader {
            let offset = tableView.contentOffset.y * -1
            cornerView.frame.origin.y = offset
            rowHeaderView.frame.origin.y = offset
        } else {
            cornerView.frame.origin.y = 0
            rowHeaderView.frame.origin.y = 0
        }

        rowHeaderView.contentOffset.x = tableView.contentOffset.x
        columnHeaderView.contentOffset.y = tableView.contentOffset.y

        overlayView.contentOffset = tableView.contentOffset

        setNeedsLayout()
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let indexPath = pendingSelectionIndexPath else {
            return
        }
        cellsForItem(at: indexPath).forEach { $0.setSelected(true, animated: true) }
        delegate?.spreadsheetView(self, didSelectItemAt: indexPath)
        pendingSelectionIndexPath = nil
    }

    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        adjustScrollViewSizes()
        adjustOverlayViewContentSize()
    }
}

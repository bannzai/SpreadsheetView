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

        let contentInset: UIEdgeInsets
        if #available(iOS 11.0, *) {
            #if swift(>=3.2)
            contentInset = rootView.adjustedContentInset
            #else
            contentInset = rootView.value(forKey: "adjustedContentInset") as! UIEdgeInsets
            #endif
        } else {
            contentInset = rootView.contentInset
        }

        if tableView.contentOffset.x < 0 && !stickyColumnHeader {
            let offset = tableView.contentOffset.x * -1 - contentInset.left
            cornerView.frame.origin.x = offset
            columnHeaderView.frame.origin.x = offset
        } else {
            cornerView.frame.origin.x = -contentInset.left
            columnHeaderView.frame.origin.x = -contentInset.left
        }
        if tableView.contentOffset.y < 0 && !stickyRowHeader {
            let offset = tableView.contentOffset.y * -1 - contentInset.top
            cornerView.frame.origin.y = offset
            rowHeaderView.frame.origin.y = offset
        } else {
            cornerView.frame.origin.y = -contentInset.top
            rowHeaderView.frame.origin.y = -contentInset.top
        }

        rowHeaderView.contentOffset.x = tableView.contentOffset.x
        columnHeaderView.contentOffset.y = tableView.contentOffset.y

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
        resetScrollViewFrame()
    }
}

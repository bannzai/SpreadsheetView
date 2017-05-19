//
//  SpreadsheetView+UIScrollView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/1/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView {
    var contentOffset: CGPoint {
        get {
            return rootView.contentOffset
        }
        set {
            rootView.contentOffset = newValue
        }
    }

    var scrollIndicatorInsets: UIEdgeInsets {
        get {
            return rootView.scrollIndicatorInsets
        }
        set {
            rootView.scrollIndicatorInsets = newValue
        }
    }

    public var contentInset: UIEdgeInsets {
        get {
            return rootView.contentInset
        }
        set {
            rootView.contentInset = newValue
        }
    }

    var _isAutomaticContentOffsetAdjustmentEnabled: Bool {
        get {
            return isAutomaticContentOffsetAdjustmentEnabled
        }
    }

    var _canScrollX: Bool {
        return tableView.isScrollEnabled && tableView.contentSize.width > tableView.frame.width
    }

    var _canScrollY: Bool {
        return tableView.isScrollEnabled && tableView.contentSize.height > tableView.frame.height
    }

    var _panGestureRecognizer: UIPanGestureRecognizer? {
        get {
            return rootView.panGestureRecognizer
        }
    }

    func _setAutomaticContentOffsetAdjustmentEnabled(_ enabled: Bool) {
        isAutomaticContentOffsetAdjustmentEnabled = enabled
    }

    func _adjustContentOffsetIfNecessary() {}

    func _notifyDidScroll() {
        adjustScrollViewSizes()
        adjustOverlayViewFrame()
    }

    public override func isKind(of aClass: AnyClass) -> Bool {
        return rootView.isKind(of: aClass)
    }
}

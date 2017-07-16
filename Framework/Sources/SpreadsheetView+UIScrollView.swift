//
//  SpreadsheetView+UIScrollView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/1/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView {
    override open func isKind(of aClass: AnyClass) -> Bool {
        return rootView.isKind(of: aClass)
    }

    public var contentOffset: CGPoint {
        get {
            return tableView.contentOffset
        }
        set {
            tableView.contentOffset = newValue
        }
    }

    public var scrollIndicatorInsets: UIEdgeInsets {
        get {
            return overlayView.scrollIndicatorInsets
        }
        set {
            overlayView.scrollIndicatorInsets = newValue
        }
    }

    public var contentSize: CGSize {
        get {
            return overlayView.contentSize
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

    func _notifyDidScroll() {
        adjustScrollViewSizes()
        adjustOverlayViewContentSize()
    }

    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if overlayView.responds(to: aSelector) {
            return overlayView
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }
}

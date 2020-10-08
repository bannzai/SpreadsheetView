//
//  SpreadsheetView+UIScrollView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/1/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView {
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
            overlayView.contentInset = newValue
        }
    }

    @available(iOS 11.0, *)
    public var adjustedContentInset: UIEdgeInsets {
        get {
            return rootView.adjustedContentInset
        }
    }

    public func flashScrollIndicators() {
        overlayView.flashScrollIndicators()
    }

    public func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        tableView.setContentOffset(contentOffset, animated: animated)
    }

    public func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        tableView.scrollRectToVisible(rect, animated: animated)
    }

    func _notifyDidScroll() {
        resetScrollViewFrame()
    }
    
    public override func isKind(of aClass: AnyClass) -> Bool {
        if #available(iOS 11.0, *) {
            return super.isKind(of: aClass)
        } else {
            return rootView.isKind(of: aClass)
        }
    }

    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if #available(iOS 11.0, *) {
            return super.forwardingTarget(for: aSelector)
        } else {
            if overlayView.responds(to: aSelector) {
                return overlayView
            } else {
                return super.forwardingTarget(for: aSelector)
            }
        }
    }
}

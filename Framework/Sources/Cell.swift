//
//  Cell.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

open class Cell: UIView {
    public let contentView = UIView()

    public var backgroundView: UIView? {
        willSet {
            backgroundView?.removeFromSuperview()
        }
        didSet {
            guard let backgroundView = backgroundView else {
                return
            }
            backgroundView.frame = bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(backgroundView, at: 0)
        }
    }
    public var selectedBackgroundView: UIView? {
        willSet {
            selectedBackgroundView?.removeFromSuperview()
        }
        didSet {
            guard let selectedBackgroundView = selectedBackgroundView else {
                return
            }
            selectedBackgroundView.frame = bounds
            selectedBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            selectedBackgroundView.alpha = 0
            if let backgroundView = backgroundView {
                insertSubview(selectedBackgroundView, aboveSubview: backgroundView)
            } else {
                insertSubview(selectedBackgroundView, at: 0)
            }
        }
    }

    open var isHighlighted = false {
        didSet {
            selectedBackgroundView?.alpha = isHighlighted || isSelected ? 1 : 0
        }
    }
    open var isSelected = false {
        didSet {
            selectedBackgroundView?.alpha = isSelected ? 1 : 0
        }
    }

    public var gridlines = Gridlines(top: .default, bottom: .default, left: .default, right: .default)
    public var borders = Borders(top: .none, bottom: .none, left: .none, right: .none) {
        didSet {
            hasBorder = borders.top != .none || borders.bottom != .none || borders.left != .none || borders.right != .none
        }
    }
    var hasBorder = false

    public internal(set) var reuseIdentifier: String?

    var indexPath: IndexPath!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        backgroundColor = .white

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(contentView, at: 0)
    }

    open func prepareForReuse() {}

    func setSelected(_ selected: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                self.isSelected = selected
            }
        } else {
            isSelected = selected
        }
    }
}

extension Cell: Comparable {
    public static func <(lhs: Cell, rhs: Cell) -> Bool {
        return lhs.indexPath < rhs.indexPath
    }
}

final class BlankCell: Cell {}

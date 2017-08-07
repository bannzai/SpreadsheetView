//
//  Gridlines.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/7/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

public typealias Gridlines = RectStyle<GridStyle>

@available(*, deprecated: 0.6.3, renamed: "Gridlines")
public typealias Grids = Gridlines

public enum GridStyle {
    case `default`
    case none
    case solid(width: CGFloat, color: UIColor)
}

extension GridStyle: Equatable {
    public static func ==(lhs: GridStyle, rhs: GridStyle) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.solid(lhs), .solid(rhs)):
            return lhs.width == rhs.width && lhs.color == rhs.color
        default:
            return false
        }
    }
}

final class Gridline: CALayer {
    var color: UIColor = .clear {
        didSet {
            backgroundColor = color.cgColor
        }
    }

    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

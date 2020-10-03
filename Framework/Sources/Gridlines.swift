//
//  Gridlines.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/7/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

public struct Gridlines {
    public var top: GridStyle
    public var bottom: GridStyle
    public var left: GridStyle
    public var right: GridStyle

    public static func all(_ style: GridStyle) -> Gridlines {
        return Gridlines(top: style, bottom: style, left: style, right: style)
    }
}

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
        case let (.solid(lWidth, lColor), .solid(rWidth, rColor)):
            return lWidth == rWidth && lColor == rColor
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

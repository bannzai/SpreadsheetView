//
//  Borders.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/8/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

public struct Borders {
    public var top: BorderStyle
    public var bottom: BorderStyle
    public var left: BorderStyle
    public var right: BorderStyle

    public static func all(_ style: BorderStyle) -> Borders {
        return Borders(top: style, bottom: style, left: style, right: style)
    }
}

public enum BorderStyle {
    case none
    case solid(width: CGFloat, color: UIColor)
}

extension BorderStyle: Equatable {
    public static func ==(lhs: BorderStyle, rhs: BorderStyle) -> Bool {
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

final class Border: UIView {
    var borders: Borders = .all(.none)

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        layer.zPosition = 1000
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setFillColor(UIColor.clear.cgColor)
        if case let .solid(width, color) = borders.left {
            context.move(to: CGPoint(x: width * 0.5, y: 0))
            context.addLine(to: CGPoint(x: width * 0.5, y: bounds.height))
            context.setLineWidth(width)
            context.setStrokeColor(color.cgColor)
            context.strokePath()
        }
        if case let .solid(width, color) = borders.right {
            context.move(to: CGPoint(x: bounds.width - width * 0.5, y: 0))
            context.addLine(to: CGPoint(x: bounds.width - width * 0.5, y: bounds.height))
            context.setLineWidth(width)
            context.setStrokeColor(color.cgColor)
            context.strokePath()
        }
        if case let .solid(width, color) = borders.top {
            context.move(to: CGPoint(x: 0, y: width * 0.5))
            context.addLine(to: CGPoint(x: bounds.width, y: width * 0.5))
            context.setLineWidth(width)
            context.setStrokeColor(color.cgColor)
            context.strokePath()
        }
        if case let .solid(width, color) = borders.bottom {
            context.move(to: CGPoint(x: 0, y: bounds.height - width * 0.5))
            context.addLine(to: CGPoint(x: bounds.width, y: bounds.height - width * 0.5))
            context.setLineWidth(width)
            context.setStrokeColor(color.cgColor)
            context.strokePath()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if case let .solid(width, _) = borders.left {
            frame.origin.x -= width * 0.5
            frame.size.width += width * 0.5
        }
        if case let .solid(width, _) = borders.right {
            frame.size.width += width * 0.5
        }
        if case let .solid(width, _) = borders.top {
            frame.origin.y -= width * 0.5
            frame.size.height += width * 0.5
        }
        if case let .solid(width, _) = borders.bottom {
            frame.size.height += width * 0.5
        }
    }
}

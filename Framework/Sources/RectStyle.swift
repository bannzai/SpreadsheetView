//
//  RectStyle.swift
//  SpreadsheetView
//
//  Created by Adam Nemecek on 8/1/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//


public struct RectStyle<Style : Equatable> : Equatable {
    public var top, bottom, left, right: Style

    public init(top: Style, bottom: Style, left: Style, right: Style) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }

    public init(all style: Style) {
        self.init(top: style, bottom: style, left: style, right: style)
    }

    public static func ==(lhs: RectStyle, rhs: RectStyle) -> Bool {
        return lhs.top == rhs.top && lhs.bottom == rhs.bottom &&
               lhs.left == rhs.left && lhs.right == rhs.right
    }
}

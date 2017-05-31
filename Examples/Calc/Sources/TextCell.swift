//
//  TextCell.swift
//  Calc
//
//  Created by Kishikawa Katsumi on 2017/06/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class TextCell: Cell {
    let label = UILabel()
    var font = UIFont.systemFont(ofSize: 12)
    var textAlignment: NSTextAlignment = .left
    var text: String = "" {
        didSet {
            label.text = text
        }
    }
    var attributedText: NSAttributedString = NSAttributedString() {
        didSet {
            label.attributedText = attributedText
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = font
        label.textAlignment = textAlignment
        contentView.addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds.insetBy(dx: 2, dy: 2)
    }
}

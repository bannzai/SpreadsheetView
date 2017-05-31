//
//  HeaderCell.swift
//  Calc
//
//  Created by Kishikawa Katsumi on 2017/06/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class HeaderCell: Cell {
    let label = UILabel()
    var font = UIFont.systemFont(ofSize: 12)
    var textAlignment: NSTextAlignment = .center
    var text: String = "" {
        didSet {
            label.text = text
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
        let bgView = UIView(frame: bounds)
        bgView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        backgroundView = bgView

        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = font
        label.textAlignment = textAlignment
        contentView.addSubview(label)
    }
}

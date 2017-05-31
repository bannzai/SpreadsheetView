//
//  SelectionView.swift
//  Calc
//
//  Created by Kishikawa Katsumi on 2017/06/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class SelectionView: UIView {
    let leftCornerHandle = UIView()
    let rightCornerHandle = UIView()

    let rowHeaderHandle = UIView()
    let leftMiddleHandle = UIView()
    let rightMiddleHandle = UIView()

    let columnHeaderHandle = UIView()
    let topMiddleHandle = UIView()
    let bottomMiddleHandle = UIView()

    let borderLayer = CAShapeLayer()

    var isColumnSelectionEnabled: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    var isRowSelectionEnabled: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }

    override var bounds: CGRect {
        didSet {
            print(bounds)
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
        borderLayer.lineWidth = 3
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.blue.cgColor
        borderLayer.lineJoin = kCALineJoinRound
        layer.addSublayer(borderLayer)

        [leftCornerHandle, rightCornerHandle,
         leftMiddleHandle, rightMiddleHandle,
         topMiddleHandle, bottomMiddleHandle].forEach { (handle) in
            handle.backgroundColor = .blue
            handle.frame.size = CGSize(width: 12, height: 12)
            handle.layer.cornerRadius = 6
            handle.layer.borderWidth = 2
            handle.layer.borderColor = UIColor.white.cgColor
            handle.layer.shadowColor = UIColor.black.cgColor
            handle.layer.shadowOpacity = 0.5
            handle.layer.shadowRadius = 1
            handle.layer.shadowOffset = CGSize(width: 0, height: 1)

            addSubview(handle)
        }

        [rowHeaderHandle, columnHeaderHandle].forEach { (handle) in
            handle.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
            handle.isHidden = true
            addSubview(handle)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(rect: bounds)
        path.lineJoinStyle = .round

        borderLayer.frame = bounds
        borderLayer.path = path.cgPath

        leftCornerHandle.center = CGPoint(x: 0, y: 0)
        rightCornerHandle.center = CGPoint(x: bounds.maxX, y: bounds.maxY)

        if isColumnSelectionEnabled {
            rowHeaderHandle.frame.size.width = bounds.maxX
            rowHeaderHandle.frame.size.height = 34
            rowHeaderHandle.isHidden = false

            leftMiddleHandle.center = CGPoint(x: 0, y: bounds.midY)
            rightMiddleHandle.center = CGPoint(x: bounds.maxX, y: bounds.midY)
            leftMiddleHandle.isHidden = false
            rightMiddleHandle.isHidden = false
            leftCornerHandle.isHidden = true
            rightCornerHandle.isHidden = true
        } else {
            rowHeaderHandle.isHidden = true
            leftMiddleHandle.isHidden = true
            rightMiddleHandle.isHidden = true
            leftCornerHandle.isHidden = false
            rightCornerHandle.isHidden = false
        }
        if isRowSelectionEnabled {
            columnHeaderHandle.frame.size.width = 64
            columnHeaderHandle.frame.size.height = bounds.maxY
            columnHeaderHandle.isHidden = false

            topMiddleHandle.center = CGPoint(x: bounds.midX, y: 0)
            bottomMiddleHandle.center = CGPoint(x: bounds.midX, y: bounds.maxY)
            topMiddleHandle.isHidden = false
            bottomMiddleHandle.isHidden = false
            leftCornerHandle.isHidden = true
            rightCornerHandle.isHidden = true
        } else {
            columnHeaderHandle.isHidden = true
            topMiddleHandle.isHidden = true
            bottomMiddleHandle.isHidden = true
            leftCornerHandle.isHidden = false
            rightCornerHandle.isHidden = false
        }
    }
}

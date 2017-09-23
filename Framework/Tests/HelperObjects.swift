//
//  HelperObjects.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/30/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

class SpreadsheetViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    var spreadsheetView = SpreadsheetView()

    var numberOfColumns: (_ spreadsheetView: SpreadsheetView) -> Int = { _ in return 0 }
    var numberOfRows: (_ spreadsheetView: SpreadsheetView) -> Int = { _ in return 0 }

    var widthForColumn: (_ spreadsheetView: SpreadsheetView, _ column: Int) -> CGFloat = { _,_ in return 0 }
    var heightForRow: (_ spreadsheetView: SpreadsheetView, _ column: Int) -> CGFloat = { _,_ in return 0 }

    var cellForItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Cell? = { _,_ in return nil }

    var mergedCells: (_ spreadsheetView: SpreadsheetView) -> [CellRange] = { _ in return [] }

    var frozenColumns: (_ spreadsheetView: SpreadsheetView) -> Int = { _ in return 0 }
    var frozenRows: (_ spreadsheetView: SpreadsheetView) -> Int = { _ in return 0 }

    var shouldHighlightItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Bool = { _,_ in return true }
    var didHighlightItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Void = { _,_ in }
    var didUnhighlightItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Void = { _,_ in }
    var shouldSelectItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Bool = { _,_ in return true }
    var shouldDeselectItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Bool = { _,_ in return true }
    var didSelectItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Void = { _,_ in }
    var didDeselectItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Void = { _,_ in }

    override func viewDidLoad() {
        super.viewDidLoad()

        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self

        spreadsheetView.frame = view.bounds
        spreadsheetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let backgroundView = UIView()
        backgroundView.backgroundColor = .red
        spreadsheetView.backgroundView = backgroundView

        view.addSubview(spreadsheetView)
    }

    // DataSource

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return numberOfColumns(spreadsheetView)
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return numberOfRows(spreadsheetView)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return widthForColumn(spreadsheetView, column)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return heightForRow(spreadsheetView, row)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        return cellForItemAt(spreadsheetView, indexPath)
    }

    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        return mergedCells(spreadsheetView)
    }

    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return frozenColumns(spreadsheetView)
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return frozenRows(spreadsheetView)
    }

    // Delegate

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return shouldHighlightItemAt(spreadsheetView, indexPath)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didHighlightItemAt indexPath: IndexPath) {
        didHighlightItemAt(spreadsheetView, indexPath)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didUnhighlightItemAt indexPath: IndexPath) {
        didUnhighlightItemAt(spreadsheetView, indexPath)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return shouldSelectItemAt(spreadsheetView, indexPath)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return shouldDeselectItemAt(spreadsheetView, indexPath)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemAt(spreadsheetView, indexPath)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didDeselectItemAt indexPath: IndexPath) {
        didDeselectItemAt(spreadsheetView, indexPath)
    }
}

struct Parameters {
    let numberOfColumns: Int
    let numberOfRows: Int

    let frozenColumns: Int
    let frozenRows: Int

    var intercellSpacing: CGSize
    var gridStyle: GridStyle

    var cell: (class: Cell.Type, reuseIdentifier: String) = (class: DebugCell.self, reuseIdentifier: "cell")

    var circularScrolling: CircularScrollingConfiguration

    let columns: [CGFloat]
    let rows: [CGFloat]

    let mergedCells: [CellRange]

    var columnWidth: CGFloat {
        return columns.reduce(0) { $0 + $1 + intercellSpacing.width } + intercellSpacing.width
    }
    var rowHeight: CGFloat {
        return rows.reduce(0) { $0 + $1 + intercellSpacing.height } + intercellSpacing.height
    }

    init(numberOfColumns: Int = 50, numberOfRows: Int = 60,
         frozenColumns: Int = 0, frozenRows: Int = 0,
         intercellSpacing: CGSize = CGSize(width: 4, height: 4), gridStyle: GridStyle = .solid(width: 2, color: .blue),
         circularScrolling: CircularScrollingConfiguration = CircularScrolling.Configuration.none,
         columns: [CGFloat]? = nil, rows: [CGFloat]? = nil,
         mergedCells: [CellRange] = []) {
        if let columns = columns {
            self.numberOfColumns =  columns.count
        } else {
            self.numberOfColumns =  numberOfColumns
        }
        if let rows = rows {
            self.numberOfRows =  rows.count
        } else {
            self.numberOfRows = numberOfRows
        }

        self.frozenColumns = frozenColumns
        self.frozenRows = frozenRows

        self.intercellSpacing = intercellSpacing
        self.gridStyle = gridStyle

        self.circularScrolling = circularScrolling

        if let columns = columns {
            self.columns = columns
        } else {
            self.columns = randomArray(seeds: [50, 60, 70, 80, 90, 100, 110], count: numberOfColumns)
        }
        if let rows = rows {
            self.rows = rows
        } else {
            self.rows = randomArray(seeds: [30, 40, 50, 60, 70, 80], count: numberOfRows)
        }

        self.mergedCells = mergedCells
    }
}

class DebugCell: Cell {
    var label = UILabel()

    override var indexPath: IndexPath! {
        didSet {
            label.text = "R\(indexPath.row)C\(indexPath.column)"
        }
    }

    override func setup() {
        super.setup()
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.systemFont(ofSize: 8)
        label.textAlignment = .center
        contentView.addSubview(label)

        let bgView = UIView()
        bgView.backgroundColor = .white
        backgroundView = bgView

        let sbgView = UIView()
        sbgView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.2)
        selectedBackgroundView = sbgView
    }
}

class Touch: UITouch {
    var location = CGPoint.zero

    convenience init(location: CGPoint) {
        self.init()
        self.location = location
    }

    override func location(in view: UIView?) -> CGPoint {
        return location
    }
}

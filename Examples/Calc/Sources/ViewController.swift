//
//  ViewController.swift
//  Calc
//
//  Created by Kishikawa Katsumi on 2017/06/01.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class ViewController: UIViewController, SpreadsheetDelegate {
    let spreadsheet = Spreadsheet()

    let spreadsheetView = SpreadsheetView()
    let dataSource = SpreadsheetDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        spreadsheet.frame = view.bounds
        spreadsheet.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        spreadsheet.delegate = self
        view.addSubview(spreadsheet)
    }

    func spreadsheet(_ spreadsheet: Spreadsheet, performCellAction cellRange: CellRange, intersection: CellRange?) {
        let controller = UIAlertController(title: "\(cellRange)", message: nil, preferredStyle: .actionSheet)
        if let intersection = intersection {
            if cellRange.isEqual(cellRange: intersection) {
                controller.addAction(UIAlertAction(title: NSLocalizedString("Unmerge Cells", comment: ""), style: .default) { (action) in
                    spreadsheet.unmergeCell(cellRange: cellRange)
                })
            } else {
                controller.addAction(UIAlertAction(title: NSLocalizedString("Merge All", comment: ""), style: .default) { (action) in
                    spreadsheet.mergeCells(cellRange: cellRange)
                })
                controller.addAction(UIAlertAction(title: NSLocalizedString("Unmerge All", comment: ""), style: .default) { (action) in
                    spreadsheet.unmergeCell(cellRange: cellRange)
                })
            }
        } else if cellRange.columnCount == 1 && cellRange.rowCount == 1 {

        } else {
            controller.addAction(UIAlertAction(title: NSLocalizedString("Merge Cells", comment: ""), style: .default) { (action) in
                spreadsheet.mergeCells(cellRange: cellRange)
            })
        }
        controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        present(controller, animated: true, completion: nil)
    }
}

extension SpreadsheetView {
    func _forwardsToParentScroller() -> Bool {
        return false
    }
}

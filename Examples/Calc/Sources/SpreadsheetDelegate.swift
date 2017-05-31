//
//  SpreadsheetDelegate.swift
//  Calc
//
//  Created by Kishikawa Katsumi on 2017/06/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

public protocol SpreadsheetDelegate {
    func spreadsheet(_ spreadsheet: Spreadsheet, performCellAction cellRange: CellRange, intersection: CellRange?)
    func spreadsheet(_ spreadsheet: Spreadsheet, textShouldBeginEditingAt indexPath: IndexPath) -> Bool
    func spreadsheet(_ spreadsheet: Spreadsheet, textDidBeginEditingAt indexPath: IndexPath)
}

extension SpreadsheetDelegate {
    func spreadsheet(_ spreadsheet: Spreadsheet, textShouldBeginEditingAt indexPath: IndexPath) -> Bool { return true }
    func spreadsheet(_ spreadsheet: Spreadsheet, textDidBeginEditingAt indexPath: IndexPath) {}
}

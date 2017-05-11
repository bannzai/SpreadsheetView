//
//  CellReuseQueue.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import Foundation

class CellReuseQueue {
    var reusableCells = Set<Cell>()

    func enqueue(cell: Cell) {
        reusableCells.insert(cell)
    }

    func dequeue() -> Cell? {
        if let _ = reusableCells.first {
            return reusableCells.removeFirst()
        }
        return nil
    }
}

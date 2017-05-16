//
//  PerformanceTests.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/30/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

class PerformanceTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testHashPerformance1() {
        var set = Set<Location>()
        measure {
            for r in 0..<400 {
                for c in 0..<400 {
                    set.insert(Location(row: r, column: c))
                }
            }
        }
    }

    func testHashPerformance2() {
        var set = Set<Address>()
        measure {
            for r in 0..<400 {
                for c in 0..<400 {
                    set.insert(Address(row: r, column: c, rowIndex: r, columnIndex: c))
                }
            }
        }
    }

    func testHashPerformance3() {
        var set = Set<IndexPath>()
        measure {
            for r in 0..<1000 {
                for c in 0..<1000 {
                    set.insert(IndexPath(row: r, section: c))
                }
            }
        }
    }

    func testCellRangePerformance1() {
        var set = Set<CellRange>()
        measure {
            for r in 0..<400 {
                for c in 0..<400 {
                    set.insert(CellRange(from: (r, c), to: (r + 1, c + 1)))
                }
            }
        }
    }

    func testCellRangePerformance2() {
        var set = Set<IndexPathCellRange>()
        measure {
            for r in 0..<400 {
                for c in 0..<400 {
                    set.insert(IndexPathCellRange(from: (r, c), to: (r + 1, c + 1)))
                }
            }
        }
    }

    func testForLoop() {
        var mergedCellLayouts = [Location: CellRange]()
        var mergedCells = [CellRange]()
        for r in 0..<100 {
            for c in 0..<100 {
                mergedCells.append(CellRange(from: (r, c), to: (r + 1, c + 1)))
            }
        }
        measure {
            for mergedCell in mergedCells {
                for column in mergedCell.from.column...mergedCell.to.column {
                    for row in mergedCell.from.row...mergedCell.to.row {
                        mergedCellLayouts[Location(row: row, column: column)] = mergedCell
                    }
                }
            }
        }
    }

    func testForEach() {
        var mergedCellLayouts = [Location: CellRange]()
        var mergedCells = [CellRange]()
        for r in 0..<100 {
            for c in 0..<100 {
                mergedCells.append(CellRange(from: (r, c), to: (r + 1, c + 1)))
            }
        }
        measure {
            mergedCells.forEach { (mergedCell) in
                (mergedCell.from.column...mergedCell.to.column).forEach { (column) in
                    (mergedCell.from.row...mergedCell.to.row).forEach { (row) in
                        mergedCellLayouts[Location(row: row, column: column)] = mergedCell
                    }
                }
            }
        }
    }

    func testSum() {
        let numbers = [Int](repeating: 20, count: 100000)
        measure {
            var sum = 0
            for n in numbers {
                sum += n
            }
        }
    }

    func testReduce() {
        let numbers = [Int](repeating: 20, count: 100000)
        measure {
            let _ = numbers.reduce(0) { $0 + $1 }
        }
    }
}

public final class IndexPathCellRange: NSObject {
    public let from: IndexPath
    public let to: IndexPath

    public let columnCount: Int
    public let rowCount: Int

    var size: CGSize?

    init(from: IndexPath, to: IndexPath) {
        guard from.column <= to.column && from.row <= to.row else {
            fatalError("The value of `from` must be less than or equal to the value of `to`")
        }
        self.from = from
        self.to = to
        columnCount = to.column - from.column + 1
        rowCount = to.row - from.row + 1
    }

    public convenience init(from: (row: Int, column: Int), to: (row: Int, column: Int)) {
        self.init(from: IndexPath(row: from.row, column: from.column),
                  to: IndexPath(row: to.row, column: to.column))
    }

    @available(*, unavailable)
    @objc(initWithFromIndexPath:toIndexPath:)
    public convenience init(from: NSIndexPath, to: NSIndexPath) {
        self.init(from: from as IndexPath, to: to as IndexPath)
    }

    @available(*, unavailable)
    @objc(cellRangeFromIndexPath:toIndexPath:)
    public class func cellRange(from: NSIndexPath, to: NSIndexPath) -> IndexPathCellRange {
        return self.init(from: from as IndexPath, to: to as IndexPath)
    }

    public func contains(indexPath: IndexPath) -> Bool {
        return indexPath.row >= from.row && indexPath.row <= to.row &&
            indexPath.column >= from.column && indexPath.column <= to.column
    }
}

extension IndexPathCellRange {
    public override var description: String {
        return "R\(from.row)C\(from.column):R\(to.row)C\(to.column)"
    }

    public override var debugDescription: String {
        return description
    }
}

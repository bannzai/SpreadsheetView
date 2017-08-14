//
//  LayoutEngine.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/7/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

final class LayoutEngine {
    private let spreadsheetView: SpreadsheetView
    private let scrollView: ScrollView

    private let intercellSpacing: CGSize
    private let defaultGridStyle: GridStyle
    private let circularScrollingOptions: CircularScrolling.Configuration.Options
    private let blankCellReuseIdentifier: String
    private let highlightedIndexPaths: Set<IndexPath>
    private let selectedIndexPaths: Set<IndexPath>

    private let frozenColumns: Int
    private let frozenRows: Int

    private let columnWidthCache: [CGFloat]
    private let rowHeightCache: [CGFloat]

    private let visibleRect: CGRect
    private var cellOrigin: CGPoint

    private let startColumn: Int
    private let startRow: Int
    private let numberOfColumns: Int
    private let numberOfRows: Int
    private let columnCount: Int
    private let rowCount: Int
    private let insets: CGPoint

    private let columnRecords: [CGFloat]
    private let rowRecords: [CGFloat]

    private var mergedCellAddresses = Set<Address>()
    private var mergedCellRects = [Address: CGRect]()

    private var visibleCellAddresses = Set<Address>()

    private var horizontalGridLayouts = [Address: GridLayout]()
    private var verticalGridLayouts = [Address: GridLayout]()

    private var visibleHorizontalGridAddresses = Set<Address>()
    private var visibleVerticalGridAddresses = Set<Address>()
    private var visibleBorderAddresses = Set<Address>()

    init(spreadsheetView: SpreadsheetView, scrollView: ScrollView) {
        self.spreadsheetView = spreadsheetView
        self.scrollView = scrollView

        intercellSpacing = spreadsheetView.intercellSpacing
        defaultGridStyle = spreadsheetView.gridStyle
        circularScrollingOptions = spreadsheetView.circularScrollingOptions
        blankCellReuseIdentifier = spreadsheetView.blankCellReuseIdentifier
        highlightedIndexPaths = spreadsheetView.highlightedIndexPaths
        selectedIndexPaths = spreadsheetView.selectedIndexPaths

        frozenColumns = spreadsheetView.layoutProperties.frozenColumns
        frozenRows = spreadsheetView.layoutProperties.frozenRows
        columnWidthCache = spreadsheetView.layoutProperties.columnWidthCache
        rowHeightCache = spreadsheetView.layoutProperties.rowHeightCache

        visibleRect = CGRect(origin: scrollView.state.contentOffset, size: scrollView.state.frame.size)
        cellOrigin = CGPoint.zero

        startColumn = scrollView.layoutAttributes.startColumn
        startRow = scrollView.layoutAttributes.startRow
        numberOfColumns = scrollView.layoutAttributes.numberOfColumns
        numberOfRows = scrollView.layoutAttributes.numberOfRows
        columnCount = scrollView.layoutAttributes.columnCount
        rowCount = scrollView.layoutAttributes.rowCount
        insets = scrollView.layoutAttributes.insets

        columnRecords = scrollView.columnRecords
        rowRecords = scrollView.rowRecords
    }

    func layout() {
        guard startColumn != columnCount && startRow != rowCount else {
            return
        }

        let startRowIndex = spreadsheetView.findIndex(in: scrollView.rowRecords, for: visibleRect.origin.y - insets.y)
        cellOrigin.y = insets.y + scrollView.rowRecords[startRowIndex] + intercellSpacing.height

        for rowIndex in (startRowIndex + startRow)..<rowCount {
            let row = rowIndex % numberOfRows
            if circularScrollingOptions.tableStyle.contains(.rowHeaderNotRepeated) && startRow > 0 && row < frozenRows {
                continue
            }

            let stop = enumerateColumns(currentRow: row, currentRowIndex: rowIndex)
            if stop {
                break
            }
            cellOrigin.y += rowHeightCache[row] + intercellSpacing.height
        }

        renderMergedCells()
        renderVerticalGridlines()
        renderHorizontalGridlines()
        renderBorders()
        returnReusableResouces()
    }

    private func enumerateColumns(currentRow row: Int, currentRowIndex rowIndex: Int) -> Bool {
        let startColumnIndex = spreadsheetView.findIndex(in: columnRecords, for: visibleRect.origin.x - insets.x)
        cellOrigin.x = insets.x + columnRecords[startColumnIndex] + intercellSpacing.width

        var columnIndex = startColumnIndex + startColumn

        while columnIndex < columnCount {
            var columnStep = 1
            defer {
                columnIndex += columnStep
            }

            let column = columnIndex % numberOfColumns
            if circularScrollingOptions.tableStyle.contains(.columnHeaderNotRepeated) && startColumn > 0 && column < frozenColumns {
                continue
            }

            let columnWidth = columnWidthCache[column]

            if let mergedCell = spreadsheetView.mergedCell(for: Location(row: row, column: column)) {
                var cellWidth: CGFloat = 0
                var cellHeight: CGFloat = 0
                if let cellSize = mergedCell.size {
                    cellWidth = cellSize.width
                    cellHeight = cellSize.height
                } else {
                    for column in mergedCell.from.column...mergedCell.to.column {
                        cellWidth += columnWidthCache[column] + intercellSpacing.width
                    }
                    for row in mergedCell.from.row...mergedCell.to.row {
                        cellHeight += rowHeightCache[row] + intercellSpacing.height
                    }
                    mergedCell.size = CGSize(width: cellWidth, height: cellHeight)
                }

                columnStep += (mergedCell.columnCount - (column - mergedCell.from.column)) - 1
                let address = Address(row: mergedCell.from.row, column: mergedCell.from.column,
                                      rowIndex: rowIndex - (row - mergedCell.from.row), columnIndex: columnIndex - (column - mergedCell.from.column))

                if column < columnRecords.count {
                    let offsetWidth = columnRecords[column - startColumn] - columnRecords[mergedCell.from.column - startColumn]
                    cellOrigin.x -= offsetWidth
                } else {
                    let fromColumn = mergedCell.from.column
                    let endColumn = columnRecords.count - 1

                    var offsetWidth = columnRecords[endColumn]
                    for column in endColumn..<column {
                        offsetWidth += columnWidthCache[column] + intercellSpacing.width
                    }
                    if fromColumn < columnRecords.count {
                        offsetWidth -= columnRecords[mergedCell.from.column]
                    } else {
                        offsetWidth -= columnRecords[endColumn]
                        for column in endColumn..<fromColumn {
                            offsetWidth -= columnWidthCache[column] + intercellSpacing.width
                        }
                    }
                    cellOrigin.x -= offsetWidth
                }
                if visibleCellAddresses.contains(address) {
                    guard cellOrigin.x <= visibleRect.maxX else {
                        cellOrigin.x += cellWidth
                        return false
                    }
                    guard cellOrigin.y <= visibleRect.maxY else {
                        return true
                    }
                    cellOrigin.x += cellWidth
                    continue
                }

                var offsetHeight: CGFloat = 0
                if row < rowRecords.count {
                    offsetHeight = rowRecords[row - startRow] - rowRecords[mergedCell.from.row - startRow]
                } else {
                    let fromRow = mergedCell.from.row
                    let endRow = rowRecords.count - 1

                    offsetHeight = rowRecords[endRow]
                    for row in endRow..<row {
                        offsetHeight += rowHeightCache[row] + intercellSpacing.height
                    }
                    if fromRow < rowRecords.count {
                        offsetHeight -= rowRecords[fromRow]
                    } else {
                        offsetHeight -= rowRecords[endRow]
                        for row in endRow..<fromRow {
                            offsetHeight -= rowHeightCache[row] + intercellSpacing.height
                        }
                    }
                }

                guard cellOrigin.x + cellWidth - intercellSpacing.width > visibleRect.minX else {
                    cellOrigin.x += cellWidth
                    continue
                }
                guard cellOrigin.x <= visibleRect.maxX else {
                    cellOrigin.x += cellWidth
                    return false
                }
                guard cellOrigin.y - offsetHeight + cellHeight - intercellSpacing.height > visibleRect.minY else {
                    cellOrigin.x += cellWidth
                    continue
                }
                guard cellOrigin.y - offsetHeight <= visibleRect.maxY else {
                    return true
                }

                visibleCellAddresses.insert(address)
                if mergedCellAddresses.insert(address).inserted {
                    mergedCellRects[address] = CGRect(origin: CGPoint(x: cellOrigin.x, y: cellOrigin.y - offsetHeight),
                                                      size: CGSize(width: cellWidth - intercellSpacing.width, height: cellHeight - intercellSpacing.height))
                }

                cellOrigin.x += cellWidth
                continue
            }

            let rowHeight = rowHeightCache[row]

            guard cellOrigin.x + columnWidth > visibleRect.minX else {
                cellOrigin.x += columnWidth + intercellSpacing.width
                continue
            }
            guard cellOrigin.x <= visibleRect.maxX else {
                cellOrigin.x += columnWidth + intercellSpacing.width
                return false
            }
            guard cellOrigin.y + rowHeight > visibleRect.minY else {
                cellOrigin.x += columnWidth + intercellSpacing.width
                continue
            }
            guard cellOrigin.y <= visibleRect.maxY else {
                return true
            }

            let address = Address(row: row, column: column, rowIndex: rowIndex, columnIndex: columnIndex)
            visibleCellAddresses.insert(address)

            let cellSize = CGSize(width: columnWidth, height: rowHeight)
            layoutCell(address: address, frame: CGRect(origin: cellOrigin, size: cellSize))

            cellOrigin.x += columnWidth + intercellSpacing.width
        }

        return false
    }

    private func layoutCell(address: Address, frame: CGRect) {
        guard let dataSource = spreadsheetView.dataSource else {
            return
        }

        let gridlines: Gridlines?
        let border: (borders: Borders?, hasBorders: Bool)

        if scrollView.visibleCells.contains(address) {
            if let cell = scrollView.visibleCells[address] {
                cell.frame = frame
                gridlines = cell.gridlines
                border = (cell.borders, cell.hasBorder)
            } else {
                gridlines = nil
                border = (nil, false)
            }
        } else {
            let indexPath = IndexPath(row: address.row, column: address.column)

            let cell = dataSource.spreadsheetView(spreadsheetView, cellForItemAt: indexPath) ?? spreadsheetView.dequeueReusableCell(withReuseIdentifier: blankCellReuseIdentifier, for: indexPath)
            guard let _ = cell.reuseIdentifier else {
                fatalError("the cell returned from `spreadsheetView(_:cellForItemAt:)` does not have a `reuseIdentifier` - cells must be retrieved by calling `dequeueReusableCell(withReuseIdentifier:for:)`")
            }
            cell.indexPath = indexPath
            cell.frame = frame
            cell.isHighlighted = highlightedIndexPaths.contains(indexPath)
            cell.isSelected = selectedIndexPaths.contains(indexPath)

            gridlines = cell.gridlines
            border = (cell.borders, cell.hasBorder)

            scrollView.insertSubview(cell, at: 0)
            scrollView.visibleCells[address] = cell
        }

        if border.hasBorders {
            visibleBorderAddresses.insert(address)
        }
        if let gridlines = gridlines {
            layoutGridlines(address: address, frame: frame, gridlines: gridlines)
        }
    }

    private func layoutGridlines(address: Address, frame: CGRect, gridlines: Gridlines) {
        let (topWidth, topColor, topPriority) = extractGridStyle(style: gridlines.top)
        let (bottomWidth, bottomColor, bottomPriority) = extractGridStyle(style: gridlines.bottom)
        let (leftWidth, leftColor, leftPriority) = extractGridStyle(style: gridlines.left)
        let (rightWidth, rightColor, rightPriority) = extractGridStyle(style: gridlines.right)

        if let gridLayout = horizontalGridLayouts[address] {
            if topPriority > gridLayout.priority {
                horizontalGridLayouts[address] = GridLayout(gridWidth: topWidth, gridColor: topColor, origin: frame.origin, length: frame.width, edge: .top(left: leftWidth, right: rightWidth), priority: topPriority)
            }
        } else {
            horizontalGridLayouts[address] = GridLayout(gridWidth: topWidth, gridColor: topColor, origin: frame.origin, length: frame.width, edge: .top(left: leftWidth, right: rightWidth), priority: topPriority)
        }
        let underCellAddress = Address(row: address.row + 1, column: address.column, rowIndex: address.rowIndex + 1, columnIndex: address.columnIndex)
        if let gridLayout = horizontalGridLayouts[underCellAddress] {
            if bottomPriority > gridLayout.priority {
                horizontalGridLayouts[underCellAddress] = GridLayout(gridWidth: bottomWidth, gridColor: bottomColor, origin: CGPoint(x: frame.origin.x, y: frame.maxY), length: frame.width, edge: .bottom(left: leftWidth, right: rightWidth), priority: bottomPriority)
            }
        } else {
            horizontalGridLayouts[underCellAddress] = GridLayout(gridWidth: bottomWidth, gridColor: bottomColor, origin: CGPoint(x: frame.origin.x, y: frame.maxY), length: frame.width, edge: .bottom(left: leftWidth, right: rightWidth), priority: bottomPriority)
        }
        if let gridLayout = verticalGridLayouts[address] {
            if leftPriority > gridLayout.priority {
                verticalGridLayouts[address] = GridLayout(gridWidth: leftWidth, gridColor: leftColor, origin: frame.origin, length: frame.height, edge: .left(top: topWidth, bottom: bottomWidth), priority: leftPriority)
            }
        } else {
            verticalGridLayouts[address] = GridLayout(gridWidth: leftWidth, gridColor: leftColor, origin: frame.origin, length: frame.height, edge: .left(top: topWidth, bottom: bottomWidth), priority: leftPriority)
        }
        let nextCellAddress = Address(row: address.row, column: address.column + 1, rowIndex: address.rowIndex, columnIndex: address.columnIndex + 1)
        if let gridLayout = verticalGridLayouts[nextCellAddress] {
            if rightPriority > gridLayout.priority {
                verticalGridLayouts[nextCellAddress] = GridLayout(gridWidth: rightWidth, gridColor: rightColor, origin: CGPoint(x: frame.maxX, y: frame.origin.y), length: frame.height, edge: .right(top: topWidth, bottom: bottomWidth), priority: rightPriority)
            }
        } else {
            verticalGridLayouts[nextCellAddress] = GridLayout(gridWidth: rightWidth, gridColor: rightColor, origin: CGPoint(x: frame.maxX, y: frame.origin.y), length: frame.height, edge: .right(top: topWidth, bottom: bottomWidth), priority: rightPriority)
        }
    }

    private func renderMergedCells() {
        for address in mergedCellAddresses {
            if let frame = mergedCellRects[address] {
                layoutCell(address: address, frame: frame)
            }
        }
    }

    private func renderHorizontalGridlines() {
        for (address, gridLayout) in horizontalGridLayouts {
            var frame = CGRect.zero
            frame.origin = gridLayout.origin
            if case let .top(leftWidth, rightWidth) = gridLayout.edge {
                frame.origin.x -= leftWidth + (intercellSpacing.width - leftWidth) / 2
                frame.origin.y -= intercellSpacing.height - (intercellSpacing.height - gridLayout.gridWidth) / 2
                frame.size.width = gridLayout.length + leftWidth + (intercellSpacing.width - leftWidth) / 2 + rightWidth + (intercellSpacing.width - rightWidth) / 2
            }
            if case let .bottom(leftWidth, rightWidth) = gridLayout.edge {
                frame.origin.x -= leftWidth + (intercellSpacing.width - leftWidth) / 2
                frame.origin.y -= (gridLayout.gridWidth - intercellSpacing.height) / 2
                frame.size.width = gridLayout.length + leftWidth + (intercellSpacing.width - leftWidth) / 2 + rightWidth + (intercellSpacing.width - rightWidth) / 2
            }
            frame.size.height = gridLayout.gridWidth

            if scrollView.visibleHorizontalGridlines.contains(address) {
                if let gridline = scrollView.visibleHorizontalGridlines[address] {
                    gridline.frame = frame
                    gridline.color = gridLayout.gridColor
                    gridline.zPosition = gridLayout.priority
                }
            } else {
                let gridline = spreadsheetView.horizontalGridlineReuseQueue.dequeueOrCreate()
                gridline.frame = frame
                gridline.color = gridLayout.gridColor
                gridline.zPosition = gridLayout.priority

                scrollView.layer.addSublayer(gridline)
                scrollView.visibleHorizontalGridlines[address] = gridline
            }
            visibleHorizontalGridAddresses.insert(address)
        }
    }

    private func renderVerticalGridlines() {
        for (address, gridLayout) in verticalGridLayouts {
            var frame = CGRect.zero
            frame.origin = gridLayout.origin
            if case let .left(topWidth, bottomWidth) = gridLayout.edge {
                frame.origin.x -= intercellSpacing.width - (intercellSpacing.width - gridLayout.gridWidth) / 2
                frame.origin.y -= topWidth + (intercellSpacing.height - topWidth) / 2
                frame.size.height = gridLayout.length + topWidth + (intercellSpacing.height - topWidth) / 2 + bottomWidth + (intercellSpacing.height - bottomWidth) / 2
            }
            if case let .right(topWidth, bottomWidth) = gridLayout.edge {
                frame.origin.x -= (gridLayout.gridWidth - intercellSpacing.width) / 2
                frame.origin.y -= topWidth + (intercellSpacing.height - topWidth) / 2
                frame.size.height = gridLayout.length + topWidth + (intercellSpacing.height - topWidth) / 2 + bottomWidth + (intercellSpacing.height - bottomWidth) / 2
            }
            frame.size.width = gridLayout.gridWidth

            if scrollView.visibleVerticalGridlines.contains(address) {
                if let gridline = scrollView.visibleVerticalGridlines[address] {
                    gridline.frame = frame
                    gridline.color = gridLayout.gridColor
                    gridline.zPosition = gridLayout.priority
                }
            } else {
                let gridline = spreadsheetView.verticalGridlineReuseQueue.dequeueOrCreate()
                gridline.frame = frame
                gridline.color = gridLayout.gridColor
                gridline.zPosition = gridLayout.priority

                scrollView.layer.addSublayer(gridline)
                scrollView.visibleVerticalGridlines[address] = gridline
            }
            visibleVerticalGridAddresses.insert(address)
        }
    }

    private func renderBorders() {
        for address in visibleBorderAddresses {
            if let cell = scrollView.visibleCells[address] {
                if scrollView.visibleBorders.contains(address) {
                    if let border = scrollView.visibleBorders[address] {
                        border.borders = cell.borders
                        border.frame = cell.frame
                        border.setNeedsDisplay()
                    }
                } else {
                    let border = spreadsheetView.borderReuseQueue.dequeueOrCreate()
                    border.borders = cell.borders
                    border.frame = cell.frame
                    scrollView.addSubview(border)
                    scrollView.visibleBorders[address] = border
                }
            }
        }
    }

    private func extractGridStyle(style: GridStyle) -> (width: CGFloat, color: UIColor, priority: CGFloat) {
        let gridWidth: CGFloat
        let gridColor: UIColor
        let priority: CGFloat
        switch style {
        case .default:
            switch defaultGridStyle {
            case let .solid(width, color):
                gridWidth = width
                gridColor = color
                priority = 0
            default:
                gridWidth = 0
                gridColor = .clear
                priority = 0
            }
        case let .solid(width, color):
            gridWidth = width
            gridColor = color
            priority = 200
        case .none:
            gridWidth = 0
            gridColor = .clear
            priority = 100
        }
        return (gridWidth, gridColor, priority)
    }

    private func returnReusableResouces() {
        scrollView.visibleCells.subtract(visibleCellAddresses)
        for address in scrollView.visibleCells.addresses {
            if let cell = scrollView.visibleCells[address] {
                cell.removeFromSuperview()
                if let reuseIdentifier = cell.reuseIdentifier, let reuseQueue = spreadsheetView.cellReuseQueues[reuseIdentifier] {
                    reuseQueue.enqueue(cell)
                }
                scrollView.visibleCells[address] = nil
            }
        }
        scrollView.visibleCells.addresses = visibleCellAddresses

        scrollView.visibleVerticalGridlines.subtract(visibleVerticalGridAddresses)
        for address in scrollView.visibleVerticalGridlines.addresses {
            if let gridline = scrollView.visibleVerticalGridlines[address] {
                gridline.removeFromSuperlayer()
                spreadsheetView.verticalGridlineReuseQueue.enqueue(gridline)
                scrollView.visibleVerticalGridlines[address] = nil
            }
        }
        scrollView.visibleVerticalGridlines.addresses = visibleVerticalGridAddresses

        scrollView.visibleHorizontalGridlines.subtract(visibleHorizontalGridAddresses)
        for address in scrollView.visibleHorizontalGridlines.addresses {
            if let gridline = scrollView.visibleHorizontalGridlines[address] {
                gridline.removeFromSuperlayer()
                spreadsheetView.horizontalGridlineReuseQueue.enqueue(gridline)
                scrollView.visibleHorizontalGridlines[address] = nil
            }
        }
        scrollView.visibleHorizontalGridlines.addresses = visibleHorizontalGridAddresses

        scrollView.visibleBorders.subtract(visibleBorderAddresses)
        for address in scrollView.visibleBorders.addresses {
            if let border = scrollView.visibleBorders[address] {
                border.removeFromSuperview()
                spreadsheetView.borderReuseQueue.enqueue(border)
                scrollView.visibleBorders[address] = nil
            }
        }
        scrollView.visibleBorders.addresses = visibleBorderAddresses
    }
}

struct LayoutProperties {
    let numberOfColumns: Int
    let numberOfRows: Int
    let frozenColumns: Int
    let frozenRows: Int

    let frozenColumnWidth: CGFloat
    let frozenRowHeight: CGFloat
    let columnWidth: CGFloat
    let rowHeight: CGFloat
    let columnWidthCache: [CGFloat]
    let rowHeightCache: [CGFloat]

    let mergedCells: [CellRange]
    let mergedCellLayouts: [Location: CellRange]

    init(numberOfColumns: Int = 0, numberOfRows: Int = 0,
         frozenColumns: Int = 0, frozenRows: Int = 0,
         frozenColumnWidth: CGFloat = 0, frozenRowHeight: CGFloat = 0,
         columnWidth: CGFloat = 0, rowHeight: CGFloat = 0,
         columnWidthCache: [CGFloat] = [], rowHeightCache: [CGFloat] = [],
         mergedCells: [CellRange] = [], mergedCellLayouts: [Location: CellRange] = [:]) {
        self.numberOfColumns = numberOfColumns
        self.numberOfRows = numberOfRows
        self.frozenColumns = frozenColumns
        self.frozenRows = frozenRows
        self.frozenColumnWidth = frozenColumnWidth
        self.frozenRowHeight = frozenRowHeight
        self.columnWidth = columnWidth
        self.rowHeight = rowHeight
        self.columnWidthCache = columnWidthCache
        self.rowHeightCache = rowHeightCache
        self.mergedCells = mergedCells
        self.mergedCellLayouts = mergedCellLayouts
    }
}

struct LayoutAttributes {
    let startColumn: Int
    let startRow: Int
    let numberOfColumns: Int
    let numberOfRows: Int
    let columnCount: Int
    let rowCount: Int
    let insets: CGPoint
}

enum RectEdge {
    case top(left: CGFloat, right: CGFloat)
    case bottom(left: CGFloat, right: CGFloat)
    case left(top: CGFloat, bottom: CGFloat)
    case right(top: CGFloat, bottom: CGFloat)
}

struct GridLayout {
    let gridWidth: CGFloat
    let gridColor: UIColor
    let origin: CGPoint
    let length: CGFloat
    let edge: RectEdge
    let priority: CGFloat
}

//
//  SpreadsheetView+Layout.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/1/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView {
    public override func layoutSubviews() {
        super.layoutSubviews()

        tableView.delegate = nil
        columnHeaderView.delegate = nil
        rowHeaderView.delegate = nil
        cornerView.delegate = nil

        cornerView.state.frame = cornerView.frame
        columnHeaderView.state.frame = columnHeaderView.frame
        rowHeaderView.state.frame = rowHeaderView.frame
        tableView.state.frame = tableView.frame

        cornerView.state.contentSize = cornerView.contentSize
        columnHeaderView.state.contentSize = columnHeaderView.contentSize
        rowHeaderView.state.contentSize = rowHeaderView.contentSize
        tableView.state.contentSize = tableView.contentSize

        cornerView.state.contentOffset = cornerView.contentOffset
        columnHeaderView.state.contentOffset = columnHeaderView.contentOffset
        rowHeaderView.state.contentOffset = rowHeaderView.contentOffset
        tableView.state.contentOffset = tableView.contentOffset

        defer {
            cornerView.contentSize = cornerView.state.contentSize
            columnHeaderView.contentSize = columnHeaderView.state.contentSize
            rowHeaderView.contentSize = rowHeaderView.state.contentSize
            tableView.contentSize = tableView.state.contentSize

            cornerView.contentOffset = cornerView.state.contentOffset
            columnHeaderView.contentOffset = columnHeaderView.state.contentOffset
            rowHeaderView.contentOffset = rowHeaderView.state.contentOffset
            tableView.contentOffset = tableView.state.contentOffset

            tableView.delegate = self
            columnHeaderView.delegate = self
            rowHeaderView.delegate = self
            cornerView.delegate = self
        }

        reloadDataIfNeeded()

        guard numberOfColumns > 0 && numberOfRows > 0 else {
            return
        }

        if circularScrollingOptions.direction.contains(.horizontally) {
            recenterHorizontallyIfNecessary()
        }
        if circularScrollingOptions.direction.contains(.vertically) {
            recenterVerticallyIfNecessary()
        }

        layoutCornerView()
        layoutRowHeaderView()
        layoutColumnHeaderView()
        layoutTableView()
    }

    private func layout(scrollView: ScrollView) {
        let layoutEngine = LayoutEngine(spreadsheetView: self, scrollView: scrollView)
        layoutEngine.layout()
    }

    private func layoutCornerView() {
        guard frozenColumns > 0 && frozenRows > 0 && circularScrolling.options.headerStyle == .none else {
            cornerView.isHidden = true
            return
        }
        cornerView.isHidden = false
        layout(scrollView: cornerView)
    }

    private func layoutColumnHeaderView() {
        guard frozenColumns > 0 else {
            columnHeaderView.isHidden = true
            return
        }
        columnHeaderView.isHidden = false
        layout(scrollView: columnHeaderView)
    }

    private func layoutRowHeaderView() {
        guard frozenRows > 0 else {
            rowHeaderView.isHidden = true
            return
        }
        rowHeaderView.isHidden = false
        layout(scrollView: rowHeaderView)
    }

    private func layoutTableView() {
        layout(scrollView: tableView)
    }

    func layoutAttributeForCornerView() -> LayoutAttributes {
        return LayoutAttributes(startColumn: 0,
                                startRow: 0,
                                numberOfColumns: frozenColumns,
                                numberOfRows: frozenRows,
                                columnCount: frozenColumns,
                                rowCount: frozenRows,
                                insets: .zero)
    }

    func layoutAttributeForColumnHeaderView() -> LayoutAttributes {
        let insets = circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow ? CGPoint(x: 0, y: layoutProperties.rowHeightCache.prefix(upTo: frozenRows).reduce(0) { $0 + $1 } + intercellSpacing.height * CGFloat(layoutProperties.frozenRows)) : .zero
        return LayoutAttributes(startColumn: 0,
                                startRow: layoutProperties.frozenRows,
                                numberOfColumns: layoutProperties.frozenColumns,
                                numberOfRows: layoutProperties.numberOfRows,
                                columnCount: layoutProperties.frozenColumns,
                                rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
                                insets: insets)
    }

    func layoutAttributeForRowHeaderView() -> LayoutAttributes {
        let insets = circularScrollingOptions.headerStyle == .rowHeaderStartsFirstColumn ? CGPoint(x: layoutProperties.columnWidthCache.prefix(upTo: frozenColumns).reduce(0) { $0 + $1 } + intercellSpacing.width * CGFloat(layoutProperties.frozenColumns), y: 0) : .zero
        return LayoutAttributes(startColumn: layoutProperties.frozenColumns,
                                startRow: 0,
                                numberOfColumns: layoutProperties.numberOfColumns,
                                numberOfRows: layoutProperties.frozenRows,
                                columnCount: layoutProperties.numberOfColumns * circularScrollScalingFactor.horizontal,
                                rowCount: layoutProperties.frozenRows,
                                insets: insets)
    }

    func layoutAttributeForTableView() -> LayoutAttributes {
        return LayoutAttributes(startColumn: layoutProperties.frozenColumns,
                                startRow: layoutProperties.frozenRows,
                                numberOfColumns: layoutProperties.numberOfColumns,
                                numberOfRows: layoutProperties.numberOfRows,
                                columnCount: layoutProperties.numberOfColumns * circularScrollScalingFactor.horizontal,
                                rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
                                insets: .zero)
    }

    func resetLayoutProperties() -> LayoutProperties {
        guard let dataSource = dataSource else {
            return LayoutProperties()
        }

        let numberOfColumns = dataSource.numberOfColumns(in: self)
        let numberOfRows = dataSource.numberOfRows(in: self)

        let frozenColumns = dataSource.frozenColumns(in: self)
        let frozenRows = dataSource.frozenRows(in: self)

        guard numberOfColumns >= 0 else {
            fatalError("`numberOfColumns(in:)` must return a value greater than or equal to 0")
        }
        guard numberOfRows >= 0 else {
            fatalError("`numberOfRows(in:)` must return a value greater than or equal to 0")
        }
        guard frozenColumns <= numberOfColumns else {
            fatalError("`frozenColumns(in:) must return a value less than or equal to `numberOfColumns(in:)`")
        }
        guard frozenRows <= numberOfRows else {
            fatalError("`frozenRows(in:) must return a value less than or equal to `numberOfRows(in:)`")
        }

        let mergedCells = dataSource.mergedCells(in: self)
        let mergedCellLayouts: [Location: CellRange] = { () in
            var layouts = [Location: CellRange]()
            for mergedCell in mergedCells {
                if (mergedCell.from.column < frozenColumns && mergedCell.to.column >= frozenColumns) ||
                    (mergedCell.from.row < frozenRows && mergedCell.to.row >= frozenRows) {
                    fatalError("cannot merge frozen and non-frozen column or rows")
                }
                for column in mergedCell.from.column...mergedCell.to.column {
                    for row in mergedCell.from.row...mergedCell.to.row {
                        guard column < numberOfColumns && row < numberOfRows else {
                            fatalError("the range of `mergedCell` cannot exceed the total column or row count")
                        }
                        let location = Location(row: row, column: column)
                        if let existingMergedCell = layouts[location] {
                            if existingMergedCell.contains(mergedCell) {
                                continue
                            }
                            if mergedCell.contains(existingMergedCell) {
                                layouts[location] = nil
                            } else {
                                fatalError("cannot merge cells in a range that overlap existing merged cells")
                            }
                        }
                        mergedCell.size = nil
                        layouts[location] = mergedCell
                    }
                }
            }
            return layouts
        }()

        var columnWidthCache = [CGFloat]()
        var frozenColumnWidth: CGFloat = 0
        for column in 0..<frozenColumns {
            let width = dataSource.spreadsheetView(self, widthForColumn: column)
            columnWidthCache.append(width)
            frozenColumnWidth += width
        }
        var tableWidth: CGFloat = 0
        for column in frozenColumns..<numberOfColumns {
            let width = dataSource.spreadsheetView(self, widthForColumn: column)
            columnWidthCache.append(width)
            tableWidth += width
        }
        let columnWidth = frozenColumnWidth + tableWidth

        var rowHeightCache = [CGFloat]()
        var frozenRowHeight: CGFloat = 0
        for row in 0..<frozenRows {
            let height = dataSource.spreadsheetView(self, heightForRow: row)
            rowHeightCache.append(height)
            frozenRowHeight += height
        }
        var tableHeight: CGFloat = 0
        for row in frozenRows..<numberOfRows {
            let height = dataSource.spreadsheetView(self, heightForRow: row)
            rowHeightCache.append(height)
            tableHeight += height
        }
        let rowHeight = frozenRowHeight + tableHeight

        return LayoutProperties(numberOfColumns: numberOfColumns, numberOfRows: numberOfRows,
                                frozenColumns: frozenColumns, frozenRows: frozenRows,
                                frozenColumnWidth: frozenColumnWidth, frozenRowHeight: frozenRowHeight,
                                columnWidth: columnWidth, rowHeight: rowHeight,
                                columnWidthCache: columnWidthCache, rowHeightCache: rowHeightCache,
                                mergedCells: mergedCells, mergedCellLayouts: mergedCellLayouts)
    }

    func resetContentSize(of scrollView: ScrollView) {
        defer {
            scrollView.contentSize = scrollView.state.contentSize
        }

        scrollView.columnRecords.removeAll()
        scrollView.rowRecords.removeAll()

        let startColumn = scrollView.layoutAttributes.startColumn
        let columnCount = scrollView.layoutAttributes.columnCount
        var width: CGFloat = 0
        for column in startColumn..<columnCount {
            scrollView.columnRecords.append(width)
            let index = column % numberOfColumns
            if !circularScrollingOptions.tableStyle.contains(.columnHeaderNotRepeated) || index >= startColumn {
                width += layoutProperties.columnWidthCache[index] + intercellSpacing.width
            }
        }

        let startRow = scrollView.layoutAttributes.startRow
        let rowCount = scrollView.layoutAttributes.rowCount
        var height: CGFloat = 0
        for row in startRow..<rowCount {
            scrollView.rowRecords.append(height)
            let index = row % numberOfRows
            if !circularScrollingOptions.tableStyle.contains(.rowHeaderNotRepeated) || index >= startRow {
                height += layoutProperties.rowHeightCache[index] + intercellSpacing.height
            }
        }

        scrollView.state.contentSize = CGSize(width: width + intercellSpacing.width, height: height + intercellSpacing.height)
    }

    func resetScrollViewFrame() {
        defer {
            cornerView.frame = cornerView.state.frame
            columnHeaderView.frame = columnHeaderView.state.frame
            rowHeaderView.frame = rowHeaderView.state.frame
            tableView.frame = tableView.state.frame
        }

        let contentInset: UIEdgeInsets
        if #available(iOS 11.0, *) {
            contentInset = rootView.adjustedContentInset
        } else {
            contentInset = rootView.contentInset
        }
        let horizontalInset = contentInset.left + contentInset.right
        let verticalInset = contentInset.top + contentInset.bottom

        cornerView.state.frame = CGRect(origin: .zero, size: cornerView.state.contentSize)
        columnHeaderView.state.frame = CGRect(x: 0, y: 0, width: columnHeaderView.state.contentSize.width, height: frame.height)
        rowHeaderView.state.frame = CGRect(x: 0, y: 0, width: frame.width, height: rowHeaderView.state.contentSize.height)
        tableView.state.frame = CGRect(origin: .zero, size: frame.size)

        if frozenColumns > 0 {
            tableView.state.frame.origin.x = columnHeaderView.state.frame.width - intercellSpacing.width
            tableView.state.frame.size.width = (frame.width - horizontalInset) - (columnHeaderView.state.frame.width - intercellSpacing.width)

            if circularScrollingOptions.headerStyle != .rowHeaderStartsFirstColumn {
                rowHeaderView.state.frame.origin.x = tableView.state.frame.origin.x
                rowHeaderView.state.frame.size.width = tableView.state.frame.size.width
            }
        } else {
            tableView.state.frame.size.width = frame.width - horizontalInset
        }
        if frozenRows > 0 {
            tableView.state.frame.origin.y = rowHeaderView.state.frame.height - intercellSpacing.height
            tableView.state.frame.size.height = (frame.height - verticalInset) - (rowHeaderView.state.frame.height - intercellSpacing.height)

            if circularScrollingOptions.headerStyle != .columnHeaderStartsFirstRow {
                columnHeaderView.state.frame.origin.y = tableView.state.frame.origin.y
                columnHeaderView.state.frame.size.height = tableView.state.frame.size.height
            }
        } else {
            tableView.state.frame.size.height = frame.height - verticalInset
        }
        
        resetOverlayViewContentSize(contentInset)
    }

    func resetOverlayViewContentSize(_ contentInset: UIEdgeInsets) {
        let width = contentInset.left + contentInset.right + tableView.state.frame.origin.x + tableView.state.contentSize.width
        let height = contentInset.top + contentInset.bottom + tableView.state.frame.origin.y + tableView.state.contentSize.height
        overlayView.contentSize = CGSize(width: width, height: height)
        overlayView.contentOffset.x = tableView.state.contentOffset.x - contentInset.left
        overlayView.contentOffset.y = tableView.state.contentOffset.y - contentInset.top
    }

    func resetScrollViewArrangement() {
        tableView.removeFromSuperview()
        columnHeaderView.removeFromSuperview()
        rowHeaderView.removeFromSuperview()
        cornerView.removeFromSuperview()
        if circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow {
            rootView.addSubview(tableView)
            rootView.addSubview(rowHeaderView)
            rootView.addSubview(columnHeaderView)
            rootView.addSubview(cornerView)
        } else {
            rootView.addSubview(tableView)
            rootView.addSubview(columnHeaderView)
            rootView.addSubview(rowHeaderView)
            rootView.addSubview(cornerView)
        }
    }

    func findIndex(in records: [CGFloat], for offset: CGFloat) -> Int {
        let index = records.insertionIndex(of: offset)
        return index == 0 ? 0 : index - 1
    }
}

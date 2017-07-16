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
        defer {
            tableView.delegate = self
            columnHeaderView.delegate = self
            rowHeaderView.delegate = self
            cornerView.delegate = self

            needsReload = false
        }

        reloadDataIfNeeded()

        guard numberOfColumns > 0 && numberOfRows > 0 else {
            return
        }

        layoutCorner()
        layoutRowHeader()
        layoutColumnHeader()

        if needsReload {
            adjustScrollViewFrames()

            if circularScrollingOptions.direction.contains(.horizontally) {
                scrollToHorizontalCenter()
                if circularScrollingOptions.headerStyle == .rowHeaderStartsFirstColumn {
                    layoutRowHeader()
                }
            }
            if circularScrollingOptions.direction.contains(.vertically) {
                scrollToVerticalCenter()
                if circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow {
                    layoutColumnHeader()
                }
            }
        }

        layoutTable()

        if needsReload {
            adjustOverlayViewContentSize()
            arrangeScrollViews()
        }

        if circularScrollingOptions.direction.contains(.horizontally) {
            recenterHorizontallyIfNecessary()
        }
        if circularScrollingOptions.direction.contains(.vertically) {
            recenterVerticallyIfNecessary()
        }
    }

    func layout(scrollView: ScrollView) {
        let layoutEngine = LayoutEngine(spreadsheetView: self, scrollView: scrollView)
        layoutEngine.layout()
    }

    func layoutCorner() {
        guard frozenColumns > 0 && frozenRows > 0 && circularScrolling.options.headerStyle == .none else {
                cornerView.frame.size = CGSize.zero
                cornerView.isHidden = true
                return
        }
        cornerView.isHidden = false

        layout(scrollView: cornerView)
    }

    func layoutColumnHeader() {
        guard frozenColumns > 0 else {
            columnHeaderView.frame.size.width = 0
            columnHeaderView.isHidden = true
            return
        }
        columnHeaderView.isHidden = false

        layout(scrollView: columnHeaderView)
    }

    func layoutRowHeader() {
        guard frozenRows > 0 else {
            rowHeaderView.frame.size.height = 0
            rowHeaderView.isHidden = true
            return
        }
        rowHeaderView.isHidden = false

        layout(scrollView: rowHeaderView)
    }

    func layoutTable() {
        layout(scrollView: tableView)
    }

    func layoutAttributeForCornerView() -> LayoutAttributes {
        return LayoutAttributes(startColumn: 0,
                                startRow: 0,
                                numberOfColumns: frozenColumns,
                                numberOfRows: frozenRows,
                                columnCount: frozenColumns,
                                rowCount: frozenRows,
                                insets: CGPoint.zero)
    }

    func layoutAttributeForColumnHeaderView() -> LayoutAttributes {
        let insets = circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow ? CGPoint(x: 0, y: layoutProperties.rowHeightCache.prefix(upTo: frozenRows).reduce(0) { $0 + $1 } + intercellSpacing.height * CGFloat(layoutProperties.frozenRows)) : CGPoint.zero
        return LayoutAttributes(startColumn: 0,
                                startRow: layoutProperties.frozenRows,
                                numberOfColumns: layoutProperties.frozenColumns,
                                numberOfRows: layoutProperties.numberOfRows,
                                columnCount: layoutProperties.frozenColumns,
                                rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
                                insets: insets)
    }

    func layoutAttributeForRowHeaderView() -> LayoutAttributes {
        let insets = circularScrollingOptions.headerStyle == .rowHeaderStartsFirstColumn ? CGPoint(x: layoutProperties.columnWidthCache.prefix(upTo: frozenColumns).reduce(0) { $0 + $1 } + intercellSpacing.width * CGFloat(layoutProperties.frozenColumns), y: 0) : CGPoint.zero
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
                                insets: CGPoint.zero)
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

        scrollView.contentSize = CGSize(width: width + intercellSpacing.width, height: height + intercellSpacing.height)
    }

    func adjustScrollViewFrames() {
        let contentInset: UIEdgeInsets
        if #available(iOS 11.0, *) {
            contentInset = rootView.value(forKey: "adjustedContentInset") as! UIEdgeInsets
        } else {
            contentInset = rootView.contentInset
        }
        if frozenColumns > 0 {
            if circularScrollingOptions.headerStyle != .columnHeaderStartsFirstRow {
                columnHeaderView.frame.origin.y = frozenRows > 0 ? rowHeaderView.frame.height : 0
            }

            let height = rootView.frame.height - (contentInset.top + contentInset.bottom) - (circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow ? 0 : rowHeaderView.frame.height)
            columnHeaderView.frame.size.height = height < 0 ? 0 : height

            tableView.frame.origin.x = columnHeaderView.frame.width - intercellSpacing.width
            tableView.frame.size.width = (rootView.frame.width - (contentInset.left + contentInset.right)) - (columnHeaderView.frame.width - intercellSpacing.width)
        } else {
            tableView.frame.size.width = (rootView.frame.width - (contentInset.left + contentInset.right))
        }
        if frozenRows > 0 {
            if circularScrollingOptions.headerStyle != .rowHeaderStartsFirstColumn {
                rowHeaderView.frame.origin.x = frozenColumns > 0 ? columnHeaderView.frame.width : 0
            }

            let width = rootView.frame.width - (contentInset.left + contentInset.right) - (circularScrollingOptions.headerStyle == .rowHeaderStartsFirstColumn ? 0 : columnHeaderView.frame.width)
            rowHeaderView.frame.size.width = width < 0 ? 0 : width

            tableView.frame.origin.y = rowHeaderView.frame.height - intercellSpacing.height
            tableView.frame.size.height = (rootView.frame.height - (contentInset.top + contentInset.bottom)) - (rowHeaderView.frame.height - intercellSpacing.height)
        } else {
            tableView.frame.size.height = (rootView.frame.height - (contentInset.top + contentInset.bottom))
        }
        if frozenColumns > 0 && frozenRows > 0 {
            if circularScrollingOptions.headerStyle != .columnHeaderStartsFirstRow {
                columnHeaderView.frame.origin.y -= intercellSpacing.height
                columnHeaderView.frame.size.height += intercellSpacing.height
            }
            if circularScrollingOptions.headerStyle != .rowHeaderStartsFirstColumn {
                rowHeaderView.frame.origin.x -= intercellSpacing.width
                rowHeaderView.frame.size.width += intercellSpacing.width
            }
        }
    }

    func adjustScrollViewSizes() {
        let contentInset: UIEdgeInsets
        if #available(iOS 11.0, *) {
            contentInset = rootView.value(forKey: "adjustedContentInset") as! UIEdgeInsets
        } else {
            contentInset = rootView.contentInset
        }

        let width = rootView.frame.width - contentInset.left - contentInset.right +
            (frozenColumns > 0 ? -columnHeaderView.frame.width + intercellSpacing.width : 0)
        if width > 0 {
            if width != tableView.frame.size.width {
                rowHeaderView.frame.size.width = width
                tableView.frame.size.width = width
            }
        } else {
            rowHeaderView.frame.size.width = 0
            tableView.frame.size.width = 0
        }

        let height = rootView.frame.height - contentInset.top - contentInset.bottom +
            (frozenRows > 0 ? -rowHeaderView.frame.height + intercellSpacing.height : 0)
        if height > 0 {
            if height != tableView.frame.size.height {
                columnHeaderView.frame.size.height = height
                tableView.frame.size.height = height
            }
        } else {
            columnHeaderView.frame.size.height = 0
            tableView.frame.size.height = 0
        }
    }

    func adjustOverlayViewContentSize() {
        let contentInset: UIEdgeInsets
        if #available(iOS 11.0, *) {
            contentInset = rootView.value(forKey: "adjustedContentInset") as! UIEdgeInsets
        } else {
            contentInset = rootView.contentInset
        }
        let width = contentInset.left + contentInset.right + tableView.frame.origin.x - intercellSpacing.width + tableView.contentSize.width
        let height = contentInset.top + contentInset.bottom + tableView.frame.origin.y - intercellSpacing.height + tableView.contentSize.height
        overlayView.contentSize = CGSize(width: width, height: height)
    }

    func arrangeScrollViews() {
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

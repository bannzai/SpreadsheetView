//
//  SpreadsheetView+Layout.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/1/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView {
  open override func layoutSubviews() {
    super.layoutSubviews()
    
    tableView.delegate = nil
    columnHeaderView.delegate = nil
    columnHeaderViewRight.delegate = nil
    rowHeaderView.delegate = nil
    cornerView.delegate = nil
    cornerViewRight.delegate = nil
    
    cornerView.state.frame = cornerView.frame
    cornerViewRight.state.frame = cornerViewRight.frame
    columnHeaderView.state.frame = columnHeaderView.frame
    columnHeaderViewRight.state.frame = columnHeaderViewRight.frame
    rowHeaderView.state.frame = rowHeaderView.frame
    tableView.state.frame = tableView.frame
    
    cornerView.state.contentSize = cornerView.contentSize
    cornerViewRight.state.contentSize = cornerViewRight.contentSize
    columnHeaderView.state.contentSize = columnHeaderView.contentSize
    columnHeaderViewRight.state.contentSize = columnHeaderViewRight.contentSize
    rowHeaderView.state.contentSize = rowHeaderView.contentSize
    tableView.state.contentSize = tableView.contentSize
    
    cornerView.state.contentOffset = cornerView.contentOffset
    cornerViewRight.state.contentOffset = cornerViewRight.contentOffset
    columnHeaderView.state.contentOffset = columnHeaderView.contentOffset
    columnHeaderViewRight.state.contentOffset = columnHeaderViewRight.contentOffset
    rowHeaderView.state.contentOffset = rowHeaderView.contentOffset
    tableView.state.contentOffset = tableView.contentOffset
    
    defer {
      cornerView.contentSize = cornerView.state.contentSize
      cornerViewRight.contentSize = cornerViewRight.state.contentSize
      columnHeaderView.contentSize = columnHeaderView.state.contentSize
      columnHeaderViewRight.contentSize = columnHeaderViewRight.state.contentSize
      rowHeaderView.contentSize = rowHeaderView.state.contentSize
      tableView.contentSize = tableView.state.contentSize
      
      cornerView.contentOffset = cornerView.state.contentOffset
      cornerViewRight.contentOffset = cornerViewRight.state.contentOffset
      columnHeaderView.contentOffset = columnHeaderView.state.contentOffset
      columnHeaderViewRight.contentOffset = columnHeaderViewRight.state.contentOffset
      rowHeaderView.contentOffset = rowHeaderView.state.contentOffset
      tableView.contentOffset = tableView.state.contentOffset
      
      tableView.delegate = self
      columnHeaderView.delegate = self
      columnHeaderViewRight.delegate = self
      rowHeaderView.delegate = self
      cornerView.delegate = self
      cornerViewRight.delegate = self
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
    layoutDividerViews()
  }
  
  private func layoutDividerViews() {
    let leftFoldedColumnsWidth = layoutProperties.columnWidthCache.prefix(upTo: frozenColumns).reduce(0) { $0 + $1 + intercellSpacing.width }
    let rightFoldedColumnsWidth = layoutProperties.columnWidthCache.reversed().prefix(upTo: frozenColumnsRight).reduce(0) { $0 + $1 + intercellSpacing.width }
    
    if frozenColumns < 1 {
      columnHeaderView.rightBorder?.removeFromSuperlayer()
    } else {
      columnHeaderView.addRightBorder(color: UIColor.clear, thickness: self.dividerThickness)
    }
    
    if frozenColumnsRight < 1 {
      columnHeaderViewRight.leftBorder?.removeFromSuperlayer()
    } else {
      columnHeaderViewRight.addLeftBorder(color: self.dividerColor, thickness: self.dividerThickness)
    }
    
    if frozenColumns < 1 && frozenRows < 1 && circularScrolling.options.headerStyle != .none {
      cornerView.rightBorder?.removeFromSuperlayer()
    } else {
      cornerView.addRightBorder(color: UIColor.clear, thickness: self.dividerThickness)
    }
    
    if frozenColumnsRight < 1 && frozenRows < 1 && circularScrolling.options.headerStyle != .none {
      cornerViewRight.leftBorder?.removeFromSuperlayer()
    } else {
      cornerViewRight.addLeftBorder(color: self.dividerColor, thickness: self.dividerThickness)
    }
    
    if tableView.contentOffset.x > (tableView.contentSize.width - self.frame.width + leftFoldedColumnsWidth) && !stickyColumnHeader {
      let offset = tableView.contentOffset.x
      cornerViewRight.frame.origin.x = tableView.contentSize.width - rightFoldedColumnsWidth - offset + leftFoldedColumnsWidth
      columnHeaderViewRight.frame.origin.x = tableView.contentSize.width - rightFoldedColumnsWidth - offset + leftFoldedColumnsWidth
    } else {
      cornerViewRight.frame.origin.x = self.frame.size.width - rightFoldedColumnsWidth
      columnHeaderViewRight.frame.origin.x = self.frame.size.width - rightFoldedColumnsWidth
    }
    
    if tableView.contentOffset.x < (tableView.contentSize.width - self.frame.width + leftFoldedColumnsWidth) && !stickyColumnHeader {
      cornerViewRight.leftBorder?.backgroundColor = self.dividerColor.cgColor
      columnHeaderViewRight.leftBorder?.backgroundColor = self.dividerColor.cgColor
    } else {
      cornerViewRight.leftBorder?.backgroundColor = UIColor.clear.cgColor
      columnHeaderViewRight.leftBorder?.backgroundColor = UIColor.clear.cgColor
    }
    
    if tableView.contentOffset.x > 0 && !stickyColumnHeader {
      cornerView.rightBorder?.backgroundColor = self.dividerColor.cgColor
      columnHeaderView.rightBorder?.backgroundColor = self.dividerColor.cgColor
    } else {
      cornerView.rightBorder?.backgroundColor = UIColor.clear.cgColor
      columnHeaderView.rightBorder?.backgroundColor = UIColor.clear.cgColor
    }
  }
  
  //    private func layout(scrollView: ScrollView) {
  //        let layoutEngine = LayoutEngine(spreadsheetView: self, scrollView: scrollView)
  //        layoutEngine.layout()
  //    }
  
  private func layoutCornerView() {
    if frozenColumns < 1 && frozenRows < 1 && circularScrolling.options.headerStyle != .none {
      cornerView.isHidden = true
    } else {
      cornerView.isHidden = false
      layout(scrollView: cornerView)
    }
    
    if frozenColumnsRight < 1 && frozenRows < 1 && circularScrolling.options.headerStyle != .none {
      cornerViewRight.isHidden = true
    } else {
      cornerViewRight.isHidden = false
      layout(scrollView: cornerViewRight)
    }
    
    //        guard frozenColumns > 0 && frozenRows > 0 && circularScrolling.options.headerStyle == .none else {
    //            cornerView.isHidden = true
    //            return
    //        }
    //
    //        cornerView.isHidden = false
    //        layout(scrollView: cornerView)
  }
  
  private func layoutColumnHeaderView() {
    if frozenColumns < 1 {
      columnHeaderView.isHidden = true
    } else {
      columnHeaderView.isHidden = false
      layout(scrollView: columnHeaderView)
    }
    
    if frozenColumnsRight < 1 {
      columnHeaderViewRight.isHidden = true
    } else {
      columnHeaderViewRight.isHidden = false
      layout(scrollView: columnHeaderViewRight)
    }
    
    //        guard frozenColumns > 0 else {
    //            columnHeaderView.isHidden = true
    //            return
    //        }
    //
    //        columnHeaderView.isHidden = false
    //        layout(scrollView: columnHeaderView)
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
  
  //    func layoutAttributeForCornerView() -> LayoutAttributes {
  //        return LayoutAttributes(startColumn: 0,
  //                                startRow: 0,
  //                                numberOfColumns: frozenColumns,
  //                                numberOfRows: frozenRows,
  //                                columnCount: frozenColumns,
  //                                rowCount: frozenRows,
  //                                insets: .zero)
  //    }
  //  
  //    func layoutAttributeForCornerViewRight() -> LayoutAttributes {
  //      return LayoutAttributes(startColumn: layoutProperties.numberOfColumns - frozenColumnsRight,
  //                              startRow: 0,
  //                              numberOfColumns: frozenColumnsRight,
  //                              numberOfRows: frozenRows,
  //                              columnCount: layoutProperties.numberOfColumns,
  //                              rowCount: frozenRows,
  //                              insets: .zero)
  //    }
  //
  //    func layoutAttributeForColumnHeaderView() -> LayoutAttributes {
  //        let insets = circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow ? CGPoint(x: 0, y: layoutProperties.rowHeightCache.prefix(upTo: frozenRows).reduce(0) { $0 + $1 } + intercellSpacing.height * CGFloat(layoutProperties.frozenRows)) : .zero
  //        return LayoutAttributes(startColumn: 0,
  //                                startRow: layoutProperties.frozenRows,
  //                                numberOfColumns: layoutProperties.frozenColumns,
  //                                numberOfRows: layoutProperties.numberOfRows,
  //                                columnCount: layoutProperties.frozenColumns,
  //                                rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
  //                                insets: insets)
  //    }
  //  
  //    func layoutAttributeForColumnHeaderViewRight() -> LayoutAttributes {
  //      let insets = circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow ? CGPoint(x: 0, y: layoutProperties.rowHeightCache.prefix(upTo: frozenRows).reduce(0) { $0 + $1 } + intercellSpacing.height * CGFloat(layoutProperties.frozenRows)) : .zero
  //      return LayoutAttributes(startColumn: layoutProperties.numberOfColumns - frozenColumnsRight,
  //                              startRow: layoutProperties.frozenRows,
  //                              numberOfColumns: layoutProperties.frozenColumnsRight,
  //                              numberOfRows: layoutProperties.numberOfRows,
  //                              columnCount: layoutProperties.numberOfColumns,
  //                              rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
  //                              insets: insets)
  //    }
  //
  //    func layoutAttributeForRowHeaderView() -> LayoutAttributes {
  //        let insets = circularScrollingOptions.headerStyle == .rowHeaderStartsFirstColumn ? CGPoint(x: layoutProperties.columnWidthCache.prefix(upTo: frozenColumns).reduce(0) { $0 + $1 } + intercellSpacing.width * CGFloat(layoutProperties.frozenColumns), y: 0) : .zero
  //        return LayoutAttributes(startColumn: layoutProperties.frozenColumns,
  //                                startRow: 0,
  //                                numberOfColumns: layoutProperties.numberOfColumns,
  //                                numberOfRows: layoutProperties.frozenRows,
  //                                columnCount: layoutProperties.numberOfColumns * circularScrollScalingFactor.horizontal,
  //                                rowCount: layoutProperties.frozenRows,
  //                                insets: insets)
  //    }
  //
  //    func layoutAttributeForTableView() -> LayoutAttributes {
  //        return LayoutAttributes(startColumn: layoutProperties.frozenColumns,
  //                                startRow: layoutProperties.frozenRows,
  //                                numberOfColumns: layoutProperties.numberOfColumns,
  //                                numberOfRows: layoutProperties.numberOfRows,
  //                                columnCount: layoutProperties.numberOfColumns * circularScrollScalingFactor.horizontal,
  //                                rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
  //                                insets: .zero)
  //    }
  
  //    func resetLayoutProperties() -> LayoutProperties {
  //        guard let dataSource = dataSource else {
  //            return LayoutProperties()
  //        }
  //
  //        let numberOfColumns = dataSource.numberOfColumns(in: self)
  //        let numberOfRows = dataSource.numberOfRows(in: self)
  //
  //        let frozenColumns = dataSource.frozenColumns(in: self)
  //        let frozenColumnsRight = dataSource.frozenColumnsRight(in: self)
  //        let frozenRows = dataSource.frozenRows(in: self)
  //
  //        guard numberOfColumns >= 0 else {
  //            fatalError("`numberOfColumns(in:)` must return a value greater than or equal to 0")
  //        }
  //        guard numberOfRows >= 0 else {
  //            fatalError("`numberOfRows(in:)` must return a value greater than or equal to 0")
  //        }
  //        guard frozenColumns <= numberOfColumns else {
  //            fatalError("`frozenColumns(in:) must return a value less than or equal to `numberOfColumns(in:)`")
  //        }
  //        guard frozenColumnsRight <= numberOfColumns else {
  //          fatalError("`frozenColumnsRight(in:) must return a value less than or equal to `numberOfColumns(in:)`")
  //        }
  //        guard frozenRows <= numberOfRows else {
  //            fatalError("`frozenRows(in:) must return a value less than or equal to `numberOfRows(in:)`")
  //        }
  //
  //        let mergedCells = dataSource.mergedCells(in: self)
  //        let mergedCellLayouts: [Location: CellRange] = { () in
  //            var layouts = [Location: CellRange]()
  //            for mergedCell in mergedCells {
  //                if (mergedCell.from.column < frozenColumns && mergedCell.to.column >= frozenColumns) ||
  //                    (mergedCell.from.row < frozenRows && mergedCell.to.row >= frozenRows) {
  //                    fatalError("cannot merge frozen and non-frozen column or rows")
  //                }
  //                for column in mergedCell.from.column...mergedCell.to.column {
  //                    for row in mergedCell.from.row...mergedCell.to.row {
  //                        guard column < numberOfColumns && row < numberOfRows else {
  //                            fatalError("the range of `mergedCell` cannot exceed the total column or row count")
  //                        }
  //                        let location = Location(row: row, column: column)
  //                        if let existingMergedCell = layouts[location] {
  //                            if existingMergedCell.contains(mergedCell) {
  //                                continue
  //                            }
  //                            if mergedCell.contains(existingMergedCell) {
  //                                layouts[location] = nil
  //                            } else {
  //                                fatalError("cannot merge cells in a range that overlap existing merged cells")
  //                            }
  //                        }
  //                        mergedCell.size = nil
  //                        layouts[location] = mergedCell
  //                    }
  //                }
  //            }
  //            return layouts
  //        }()
  //
  //        var columnWidthCache = [CGFloat]()
  //        var frozenColumnWidth: CGFloat = 0
  //        for column in 0..<frozenColumns {
  //            let width = dataSource.spreadsheetView(self, widthForColumn: column)
  //            columnWidthCache.append(width)
  //            frozenColumnWidth += width
  //        }
  //        var tableWidth: CGFloat = 0
  //        for column in frozenColumns..<(numberOfColumns - frozenColumnsRight) {
  //            let width = dataSource.spreadsheetView(self, widthForColumn: column)
  //            columnWidthCache.append(width)
  //            tableWidth += width
  //        }
  //        var frozenColumnWidthRight: CGFloat = 0
  //        for column in (numberOfColumns - frozenColumnsRight)..<numberOfColumns {
  //          let width = dataSource.spreadsheetView(self, widthForColumn: column)
  //          columnWidthCache.append(width)
  //          frozenColumnWidthRight += width
  //        }
  //        let columnWidth = frozenColumnWidth + tableWidth + frozenColumnWidthRight
  //
  //        var rowHeightCache = [CGFloat]()
  //        var frozenRowHeight: CGFloat = 0
  //        for row in 0..<frozenRows {
  //            let height = dataSource.spreadsheetView(self, heightForRow: row)
  //            rowHeightCache.append(height)
  //            frozenRowHeight += height
  //        }
  //        var tableHeight: CGFloat = 0
  //        for row in frozenRows..<numberOfRows {
  //            let height = dataSource.spreadsheetView(self, heightForRow: row)
  //            rowHeightCache.append(height)
  //            tableHeight += height
  //        }
  //        let rowHeight = frozenRowHeight + tableHeight
  //
  //        return LayoutProperties(numberOfColumns: numberOfColumns, numberOfRows: numberOfRows,
  //                                frozenColumns: frozenColumns, frozenColumnsRight: frozenColumnsRight, frozenRows: frozenRows,
  //                                frozenColumnWidth: frozenColumnWidth, frozenRowHeight: frozenRowHeight,
  //                                columnWidth: columnWidth, rowHeight: rowHeight,
  //                                columnWidthCache: columnWidthCache, rowHeightCache: rowHeightCache,
  //                                mergedCells: mergedCells, mergedCellLayouts: mergedCellLayouts)
  //    }
  
  //    func resetContentSize(of scrollView: ScrollView) {
  //        defer {
  //            scrollView.contentSize = scrollView.state.contentSize
  //        }
  //
  //        scrollView.columnRecords.removeAll()
  //        scrollView.rowRecords.removeAll()
  //
  //        let startColumn = scrollView.layoutAttributes.startColumn
  //        let columnCount = scrollView.layoutAttributes.columnCount
  //      
  //        var width: CGFloat = 0
  //      
  //        for column in startColumn..<columnCount {
  //            scrollView.columnRecords.append(width)
  //            let index = column % numberOfColumns
  //            if !circularScrollingOptions.tableStyle.contains(.columnHeaderNotRepeated) || index >= startColumn {
  //                width += layoutProperties.columnWidthCache[index] + intercellSpacing.width
  //            }
  //        }
  //
  //        let startRow = scrollView.layoutAttributes.startRow
  //        let rowCount = scrollView.layoutAttributes.rowCount
  //      
  //        var height: CGFloat = 0
  //      
  //        for row in startRow..<rowCount {
  //            scrollView.rowRecords.append(height)
  //            let index = row % numberOfRows
  //            if !circularScrollingOptions.tableStyle.contains(.rowHeaderNotRepeated) || index >= startRow {
  //                height += layoutProperties.rowHeightCache[index] + intercellSpacing.height
  //            }
  //        }
  //
  //        scrollView.state.contentSize = CGSize(width: width + intercellSpacing.width, height: height + intercellSpacing.height)
  //    }
  
  public func resetViewFrame() {
    resetScrollViewFrame()
  }
  
  func resetScrollViewFrame() {
    defer {
      cornerView.frame = cornerView.state.frame
      cornerViewRight.frame = cornerViewRight.state.frame
      columnHeaderView.frame = columnHeaderView.state.frame
      columnHeaderViewRight.frame = columnHeaderViewRight.state.frame
      rowHeaderView.frame = rowHeaderView.state.frame
      tableView.frame = tableView.state.frame
    }
    
    let contentInset: UIEdgeInsets
    if #available(iOS 11.0, *) {
      #if swift(>=3.2)
      contentInset = rootView.adjustedContentInset
      #else
      contentInset = rootView.value(forKey: "adjustedContentInset") as! UIEdgeInsets
      #endif
    } else {
      contentInset = rootView.contentInset
    }
    let horizontalInset = contentInset.left + contentInset.right
    let verticalInset = contentInset.top + contentInset.bottom
    
    let rightFoldedColumnsWidth = layoutProperties.columnWidthCache.reversed().prefix(upTo: frozenColumnsRight).reduce(0) { $0 + $1 + intercellSpacing.width}
    let rightFoldedColumnsOriginX = (self.frame.size.width - rightFoldedColumnsWidth)
    
    cornerView.state.frame = CGRect(origin: .zero, size: cornerView.state.contentSize)
    cornerViewRight.state.frame = CGRect(origin: CGPoint(x: rightFoldedColumnsOriginX, y: 0), size: cornerViewRight.state.contentSize)
    columnHeaderView.state.frame = CGRect(x: 0, y: 0, width: columnHeaderView.state.contentSize.width, height: frame.height)
    columnHeaderViewRight.state.frame = CGRect(x: rightFoldedColumnsOriginX, y: 0, width: columnHeaderViewRight.state.contentSize.width, height: frame.height)
    rowHeaderView.state.frame = CGRect(x: 0, y: 0, width: frame.width, height: rowHeaderView.state.contentSize.height)
    tableView.state.frame = CGRect(origin: .zero, size: frame.size)
    
    if frozenColumns > 0 || frozenColumnsRight > 0 {
      switch (frozenColumns > 0, frozenColumnsRight > 0) {
      case (true, true):
        tableView.state.frame.origin.x = columnHeaderView.state.frame.width - intercellSpacing.width
        tableView.state.frame.size.width = (frame.width - horizontalInset) - (columnHeaderView.state.frame.width - intercellSpacing.width)
        
        if circularScrollingOptions.headerStyle != .rowHeaderStartsFirstColumn {
          rowHeaderView.state.frame.origin.x = tableView.state.frame.origin.x
          rowHeaderView.state.frame.size.width = tableView.state.frame.size.width
        }
        break
      case (false, true):
        tableView.state.frame.size.width = (frame.width - horizontalInset)
        
        if circularScrollingOptions.headerStyle != .rowHeaderStartsFirstColumn {
          rowHeaderView.state.frame.origin.x = tableView.state.frame.origin.x
          rowHeaderView.state.frame.size.width = tableView.state.frame.size.width
        }
        break
      case (true, false):
        tableView.state.frame.origin.x = columnHeaderView.state.frame.width - intercellSpacing.width
        tableView.state.frame.size.width = (frame.width - horizontalInset) - (columnHeaderView.state.frame.width - intercellSpacing.width)
        
        if circularScrollingOptions.headerStyle != .rowHeaderStartsFirstColumn {
          rowHeaderView.state.frame.origin.x = tableView.state.frame.origin.x
          rowHeaderView.state.frame.size.width = tableView.state.frame.size.width
        }
        break
      default:
        break
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
        
        columnHeaderViewRight.state.frame.origin.y = tableView.state.frame.origin.y
        columnHeaderViewRight.state.frame.size.height = tableView.state.frame.size.height
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
    columnHeaderViewRight.removeFromSuperview()
    rowHeaderView.removeFromSuperview()
    cornerView.removeFromSuperview()
    cornerViewRight.removeFromSuperview()
    if circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow {
      rootView.addSubview(tableView)
      rootView.addSubview(rowHeaderView)
      rootView.addSubview(columnHeaderView)
      rootView.addSubview(columnHeaderViewRight)
      rootView.addSubview(cornerView)
      rootView.addSubview(cornerViewRight)
    } else {
      rootView.addSubview(tableView)
      rootView.addSubview(columnHeaderView)
      rootView.addSubview(columnHeaderViewRight)
      rootView.addSubview(rowHeaderView)
      rootView.addSubview(cornerView)
      rootView.addSubview(cornerViewRight)
    }
  }
  
  func findIndex(in records: [CGFloat], for offset: CGFloat) -> Int {
    let index = records.insertionIndex(of: offset)
    return index == 0 ? 0 : index - 1
  }
}

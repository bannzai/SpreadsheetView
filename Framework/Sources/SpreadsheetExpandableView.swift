//
//  SpreadsheetView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

open class SpreadsheetExpandableView: SpreadsheetView {
  
  private var numberOfSubrowsInRow = [Int: Int]()
  private var subrowsInRowHeightCache = [Int: [CGFloat]]()
  
  var selectedSubIndexPaths = Set<SubrowIndexPath>()
  var highlightedSubIndexPaths = Set<SubrowIndexPath>()
  var pendingSelectionSubIndexPath: SubrowIndexPath?
  
  /// The object that provides the data for the collection view.
  ///
  /// - Note: The data source must adopt the `SpreadsheetExpandableViewDataSource` protocol.
  ///   The spreadsheet view maintains a weak reference to the data source object.
  open weak var expandableDataSource: SpreadsheetExpandableViewDataSource?
  
  public override var dataSource: SpreadsheetViewDataSource? {
    didSet {
      if let source = dataSource as? SpreadsheetExpandableViewDataSource {
        expandableDataSource = source
      }
    }
  }
  
  /// The object that acts as the delegate of the spreadsheet view.
  /// - Note: The delegate must adopt the `SpreadsheetExpandableViewDelegate` protocol.
  ///   The spreadsheet view maintains a weak reference to the delegate object.
  ///
  ///   The delegate object is responsible for managing selection behavior and interactions with individual items.
  open weak var expandableDelegate: SpreadsheetExpandableViewDelegate?
  
  public override var delegate: SpreadsheetViewDelegate? {
    didSet {
      if let d = delegate as? SpreadsheetExpandableViewDelegate {
        expandableDelegate = d
      }
    }
  }
  
  open override func resetLayoutProperties() -> LayoutProperties {
    guard let dataSource = dataSource, let expandableDataSource = expandableDataSource, let expandableDelegate = expandableDelegate else {
      return LayoutProperties()
    }
    
    let numberOfColumns = dataSource.numberOfColumns(in: self)
    let numberOfRows = dataSource.numberOfRows(in: self)
    
    numberOfSubrowsInRow = [Int: Int]()
    for row in 0...numberOfRows - 1 {
      let numberOfSubrows = expandableDataSource.numberOfSubrows(in: self, for: row)
      numberOfSubrowsInRow[row] = numberOfSubrows
    }
    
    let frozenColumns = dataSource.frozenColumns(in: self)
    let frozenColumnsRight = dataSource.frozenColumnsRight(in: self)
    let frozenRows = dataSource.frozenRows(in: self)
    
    if frozenRows > 0 {
      for row in 0...frozenRows - 1 {
        numberOfSubrowsInRow[row] = 0
      }
    }
    
    guard numberOfColumns >= 0 else {
      fatalError("`numberOfColumns(in:)` must return a value greater than or equal to 0")
    }
    guard numberOfRows >= 0 else {
      fatalError("`numberOfRows(in:)` must return a value greater than or equal to 0")
    }
    guard frozenColumns <= numberOfColumns else {
      fatalError("`frozenColumns(in:) must return a value less than or equal to `numberOfColumns(in:)`")
    }
    guard frozenColumnsRight <= numberOfColumns else {
      fatalError("`frozenColumnsRight(in:) must return a value less than or equal to `numberOfColumns(in:)`")
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
    for column in frozenColumns..<(numberOfColumns - frozenColumnsRight) {
      let width = dataSource.spreadsheetView(self, widthForColumn: column)
      columnWidthCache.append(width)
      tableWidth += width
    }
    
    var frozenColumnWidthRight: CGFloat = 0
    for column in (numberOfColumns - frozenColumnsRight)..<numberOfColumns {
      let width = dataSource.spreadsheetView(self, widthForColumn: column)
      columnWidthCache.append(width)
      frozenColumnWidthRight += width
    }
    
    let columnWidth = frozenColumnWidth + tableWidth + frozenColumnWidthRight
    
    var rowHeightCache = [CGFloat]()
    subrowsInRowHeightCache = [Int: [CGFloat]]()
    
    var frozenRowHeight: CGFloat = 0
    for row in 0..<frozenRows {
      let height = dataSource.spreadsheetView(self, heightForRow: row)
      rowHeightCache.append(height)
      frozenRowHeight += height
    }
    
    var tableHeight: CGFloat = 0
    for row in frozenRows..<numberOfRows {
      let height = dataSource.spreadsheetView(self, heightForRow: row)
      if let subrowsCount = numberOfSubrowsInRow[row], subrowsCount > 0 {
        for subrow in 0...subrowsCount - 1 {
          let isRowExpanded = expandableDelegate.spreadsheetView(self, isItemExpandedAt: row)
          var subrowsHeightCache = subrowsInRowHeightCache[row] ?? [CGFloat]()
          let subrowheight = isRowExpanded ? expandableDataSource.spreadsheetView(self, heightForSubrow: subrow, in: row) : 0
          subrowsHeightCache.append(subrowheight)
          subrowsInRowHeightCache[row] = subrowsHeightCache
          tableHeight += subrowheight
        }
      }
      rowHeightCache.append(height)
      tableHeight += height
    }
    
    let rowHeight = frozenRowHeight + tableHeight
    
    return LayoutPropertiesExpandable(numberOfColumns: numberOfColumns, numberOfRows: numberOfRows, numberOfSubrowsInRow: numberOfSubrowsInRow,
                                      frozenColumns: frozenColumns, frozenColumnsRight: frozenColumnsRight, frozenRows: frozenRows,
                                      frozenColumnWidth: frozenColumnWidth, frozenRowHeight: frozenRowHeight,
                                      columnWidth: columnWidth, rowHeight: rowHeight,
                                      columnWidthCache: columnWidthCache, rowHeightCache: rowHeightCache, subrowsInRowHeightCache: subrowsInRowHeightCache,
                                      mergedCells: mergedCells, mergedCellLayouts: mergedCellLayouts)
  }
  
  override open func layoutAttributeForCornerView() -> LayoutAttributes {
    return LayoutAttributesExpandable(startColumn: 0,
                                      startRow: 0,
                                      numberOfColumns: frozenColumns,
                                      numberOfRows: frozenRows,
                                      columnCount: frozenColumns,
                                      rowCount: frozenRows,
                                      insets: .zero,
                                      numberOfSubrowsInRow: [:])
  }
  
  override open func layoutAttributeForCornerViewRight() -> LayoutAttributes {
    return LayoutAttributesExpandable(startColumn: layoutProperties.numberOfColumns - frozenColumnsRight,
                                      startRow: 0,
                                      numberOfColumns: frozenColumnsRight,
                                      numberOfRows: frozenRows,
                                      columnCount: layoutProperties.numberOfColumns,
                                      rowCount: frozenRows,
                                      insets: .zero,
                                      numberOfSubrowsInRow: [:])
  }
  
  override open func layoutAttributeForRowHeaderView() -> LayoutAttributes {
    let insets = circularScrollingOptions.headerStyle == .rowHeaderStartsFirstColumn ? CGPoint(x: layoutProperties.columnWidthCache.prefix(upTo: frozenColumns).reduce(0) { $0 + $1 } + intercellSpacing.width * CGFloat(layoutProperties.frozenColumns), y: 0) : .zero
    return LayoutAttributesExpandable(startColumn: layoutProperties.frozenColumns,
                                      startRow: 0,
                                      numberOfColumns: layoutProperties.numberOfColumns,
                                      numberOfRows: layoutProperties.frozenRows,
                                      columnCount: layoutProperties.numberOfColumns * circularScrollScalingFactor.horizontal,
                                      rowCount: layoutProperties.frozenRows,
                                      insets: insets,
                                      numberOfSubrowsInRow: [:])
  }
  
  override open func layoutAttributeForColumnHeaderView() -> LayoutAttributes {
    let insets = circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow ? CGPoint(x: 0, y: layoutProperties.rowHeightCache.prefix(upTo: frozenRows).reduce(0) { $0 + $1 } + intercellSpacing.height * CGFloat(layoutProperties.frozenRows)) : .zero
    return LayoutAttributesExpandable(startColumn: 0,
                                      startRow: layoutProperties.frozenRows,
                                      numberOfColumns: layoutProperties.frozenColumns,
                                      numberOfRows: layoutProperties.numberOfRows,
                                      columnCount: layoutProperties.frozenColumns,
                                      rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
                                      insets: insets,
                                      numberOfSubrowsInRow: numberOfSubrowsInRow)
  }
  
  override open func layoutAttributeForColumnHeaderViewRight() -> LayoutAttributes {
    let insets = circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow ? CGPoint(x: 0, y: layoutProperties.rowHeightCache.prefix(upTo: frozenRows).reduce(0) { $0 + $1 } + intercellSpacing.height * CGFloat(layoutProperties.frozenRows)) : .zero
    return LayoutAttributesExpandable(startColumn: layoutProperties.numberOfColumns - frozenColumnsRight,
                                      startRow: layoutProperties.frozenRows,
                                      numberOfColumns: layoutProperties.frozenColumnsRight,
                                      numberOfRows: layoutProperties.numberOfRows,
                                      columnCount: layoutProperties.numberOfColumns,
                                      rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
                                      insets: insets,
                                      numberOfSubrowsInRow: numberOfSubrowsInRow)
  }
  
  override open func layoutAttributeForTableView() -> LayoutAttributes {
    return LayoutAttributesExpandable(startColumn: layoutProperties.frozenColumns,
                                      startRow: layoutProperties.frozenRows,
                                      numberOfColumns: layoutProperties.numberOfColumns,
                                      numberOfRows: layoutProperties.numberOfRows,
                                      columnCount: layoutProperties.numberOfColumns * circularScrollScalingFactor.horizontal,
                                      rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
                                      insets: .zero,
                                      numberOfSubrowsInRow: numberOfSubrowsInRow)
  }
  
  override open func layout(scrollView: ScrollView) {
    let layoutEngine = LayoutEngineExpandable(spreadsheetView: self, scrollView: scrollView)
    layoutEngine.layout()
  }
  
  override open func resetContentSize(of scrollView: ScrollView) {
    guard let scrollViewExpandable = scrollView as? ScrollViewExpandable,
      let layoutProperties = layoutProperties as? LayoutPropertiesExpandable else {
      super.resetContentSize(of: scrollView)
      return
    }
    
    defer {
      scrollView.contentSize = scrollView.state.contentSize
    }
    
    scrollView.columnRecords.removeAll()
    scrollView.rowRecords.removeAll()
    scrollViewExpandable.subrowsInRowRecords.removeAll()
    
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
      
      let numberOfSubrows = layoutProperties.numberOfSubrowsInRow[index] ?? 0
      var subriowsHeight: CGFloat = 0
      if numberOfSubrows > 0, let subrowsHeightCache = layoutProperties.subrowsInRowHeightCache[index] {
        for subrow in 0...numberOfSubrows - 1 {
          let subrowHeight = subrowsHeightCache[subrow]
          var rowRecords = scrollViewExpandable.subrowsInRowRecords[scrollView.rowRecords.count - 1] ?? [CGFloat]()
          rowRecords.append(subriowsHeight + height)
          scrollViewExpandable.subrowsInRowRecords[scrollView.rowRecords.count - 1] = rowRecords
          subriowsHeight += subrowHeight + intercellSpacing.height
        }
      }
      height += subriowsHeight
    }
    
    scrollView.state.contentSize = CGSize(width: width + intercellSpacing.width, height: height + intercellSpacing.height)
  }
  
  override open func setup() {
    columnHeaderView = ScrollViewExpandable()
    columnHeaderViewRight = ScrollViewExpandable()
    
    rowHeaderView = ScrollViewExpandable()
    
    cornerView = ScrollViewExpandable()
    cornerViewRight = ScrollViewExpandable()
    
    tableView = ScrollViewExpandable()
    
    super.setup()
  }
  
  public func indexPathForSubItem(at point: CGPoint) -> SubrowIndexPath? {
    
    guard let tableView = self.tableView as? ScrollViewExpandable,
      let columnHeaderView = self.columnHeaderView as? ScrollViewExpandable,
      let columnHeaderViewRight = self.columnHeaderViewRight as? ScrollViewExpandable,
      let cornerView = self.cornerView as? ScrollViewExpandable,
      let cornerViewRight = self.cornerViewRight as? ScrollViewExpandable,
      let rowHeaderView = self.rowHeaderView as? ScrollViewExpandable else {
        return nil
    }
    
    var row = 0
    var column = 0
    var subrow = 0
    
    if tableView.convert(tableView.bounds, to: self).contains(point), let indexPath = indexPathForSubItem(at: point, in: tableView) {
      (row, column, subrow) = (indexPath.row + frozenRows, indexPath.column + frozenColumns, indexPath.subrow)
    } else if rowHeaderView.convert(rowHeaderView.bounds, to: self).contains(point), let indexPath = indexPathForSubItem(at: point, in: rowHeaderView) {
      (row, column, subrow) = (indexPath.row, indexPath.column + frozenColumns, indexPath.subrow)
    } else if columnHeaderView.convert(columnHeaderView.bounds, to: self).contains(point), let indexPath = indexPathForSubItem(at: point, in: columnHeaderView) {
      (row, column, subrow) = (indexPath.row + frozenRows, indexPath.column, indexPath.subrow)
    }  else if columnHeaderViewRight.convert(columnHeaderViewRight.bounds, to: self).contains(point), let indexPath = indexPathForSubItem(at: point, in: columnHeaderViewRight) {
      (row, column, subrow) = (indexPath.row + frozenRows, indexPath.column, indexPath.subrow)
    } else if cornerView.convert(cornerView.bounds, to: self).contains(point), let indexPath = indexPathForSubItem(at: point, in: cornerView) {
      (row, column, subrow) = (indexPath.row, indexPath.column, indexPath.subrow)
    } else if cornerViewRight.convert(cornerViewRight.bounds, to: self).contains(point), let indexPath = indexPathForSubItem(at: point, in: cornerViewRight) {
      (row, column, subrow) = (indexPath.row, indexPath.column, indexPath.subrow)
    } else {
      return nil
    }
    
    row = row % numberOfRows
    column = column % numberOfColumns
    
    let location = Location(row: row, column: column)
    if let mergedCell = mergedCell(for: location) {
      return SubrowIndexPath(indexPath: IndexPath(row: mergedCell.from.row, column: mergedCell.from.column), subrow: subrow)
    }
    return SubrowIndexPath(indexPath: IndexPath(row: location.row, column: location.column), subrow: subrow)
  }
  
  private func indexPathForSubItem(at location: CGPoint, in scrollView: ScrollViewExpandable) -> SubrowIndexPath? {
    let insetX = scrollView.layoutAttributes.insets.x
    let insetY = scrollView.layoutAttributes.insets.y
    
    func isPointInColumn(x: CGFloat, column: Int) -> Bool {
      guard column < scrollView.columnRecords.count else {
        return false
      }
      let minX = scrollView.columnRecords[column] + intercellSpacing.width
      let maxX = minX + layoutProperties.columnWidthCache[(column + scrollView.layoutAttributes.startColumn) % numberOfColumns]
      return x >= minX && x <= maxX
    }
    func isPointInSubRow(y: CGFloat, row: Int, subrow: Int) -> Bool {
      guard row < scrollView.rowRecords.count,
        let subrowsRecors = scrollView.subrowsInRowRecords[row],
        subrow < subrowsRecors.count,
        let layoutProperties = self.layoutProperties as? LayoutPropertiesExpandable,
        let subrowsHeightCache = layoutProperties.subrowsInRowHeightCache[(row + scrollView.layoutAttributes.startRow) % numberOfRows] else {
        return false
      }
      
      let minY = subrowsRecors[subrow] + intercellSpacing.height
      let maxY = minY + subrowsHeightCache[subrow]
      return y >= minY && y <= maxY
    }
    
    let point = convert(location, to: scrollView)
    let column = findIndex(in: scrollView.columnRecords, for: point.x - insetX)
    let row = findIndex(in: scrollView.rowRecords, for: point.y - insetY)
    let subrow = findIndex(in: scrollView.subrowsInRowRecords[row] ?? [], for: point.y - insetY)
    
    switch (isPointInColumn(x: point.x - insetX, column: column), isPointInSubRow(y: point.y, row: row, subrow: subrow)) {
    case (true, true):
      return SubrowIndexPath(indexPath: IndexPath(row: row, column: column), subrow: subrow)
    case (true, false):
      if isPointInSubRow(y: point.y - insetY, row: row, subrow: subrow + 1) {
        return SubrowIndexPath(indexPath: IndexPath(row: row, column: column), subrow: subrow + 1)
      }
      return nil
    case (false, true):
      if isPointInColumn(x: point.x - insetX, column: column + 1) {
        return SubrowIndexPath(indexPath: IndexPath(row: row, column: column + 1), subrow: subrow)
      }
      return nil
    case (false, false):
      if isPointInColumn(x: point.x - insetX, column: column + 1) && isPointInSubRow(y: point.y - insetY, row: row, subrow: subrow + 1) {
        return SubrowIndexPath(indexPath: IndexPath(row: row, column: column + 1), subrow: subrow + 1)
      }
      return nil
    }
  }
  
  public func selectSubItem(at indexPath: SubrowIndexPath?, animated: Bool, scrollPosition: ScrollPosition) {
    guard let indexPath = indexPath else {
      deselectAllSubItems(animated: animated)
      return
    }
    guard allowsSelection else {
      return
    }
    
    if !allowsMultipleSelection {
      selectedSubIndexPaths.remove(indexPath)
      deselectAllSubItems(animated: animated)
    }
    if selectedSubIndexPaths.insert(indexPath).inserted {
      if !scrollPosition.isEmpty {
        scrollToItem(at: indexPath.indexPath, at: scrollPosition, animated: animated)
        if animated {
          pendingSelectionSubIndexPath = indexPath
          return
        }
      }
      cellsForSubItem(at: indexPath).forEach {
        $0.setSelected(true, animated: animated)
      }
    }
  }
  
  public func deselectSubItem(at indexPath: SubrowIndexPath, animated: Bool) {
    cellsForSubItem(at: indexPath).forEach {
      $0.setSelected(false, animated: animated)
    }
    selectedSubIndexPaths.remove(indexPath)
  }
  
  private func deselectAllSubItems(animated: Bool) {
    selectedSubIndexPaths.forEach { deselectSubItem(at: $0, animated: animated) }
  }
  
  public func cellForSubItem(at indexPath: SubrowIndexPath) -> Cell? {
    guard let tableView = self.tableView as? ScrollViewExpandable,
      let columnHeaderView = self.columnHeaderView as? ScrollViewExpandable,
      let columnHeaderViewRight = self.columnHeaderViewRight as? ScrollViewExpandable,
      let cornerView = self.cornerView as? ScrollViewExpandable,
      let cornerViewRight = self.cornerViewRight as? ScrollViewExpandable,
      let rowHeaderView = self.rowHeaderView as? ScrollViewExpandable else {
        return nil
    }
    
    if let cell = tableView.visibleSubCells.pairs
      .filter({ $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow})
      .map({ return $1 })
      .first {
      return cell
    }
    if let cell = rowHeaderView.visibleSubCells.pairs
      .filter({ $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow})
      .map({ return $1 })
      .first {
      return cell
    }
    if let cell = columnHeaderView.visibleSubCells.pairs
      .filter({ $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow})
      .map({ return $1 })
      .first {
      return cell
    }
    if let cell = columnHeaderViewRight.visibleSubCells.pairs
      .filter({ $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow})
      .map({ return $1 })
      .first {
      return cell
    }
    if let cell = cornerView.visibleSubCells.pairs
      .filter({ $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow})
      .map({ return $1 })
      .first {
      return cell
    }
    if let cell = cornerViewRight.visibleSubCells.pairs
      .filter({ $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow})
      .map({ return $1 })
      .first {
      return cell
    }
    return nil
  }
  
  public func cellsForSubItem(at indexPath: SubrowIndexPath) -> [Cell] {
    var cells = [Cell]()
    
    guard let tableView = self.tableView as? ScrollViewExpandable,
      let columnHeaderView = self.columnHeaderView as? ScrollViewExpandable,
      let columnHeaderViewRight = self.columnHeaderViewRight as? ScrollViewExpandable,
      let cornerView = self.cornerView as? ScrollViewExpandable,
      let cornerViewRight = self.cornerViewRight as? ScrollViewExpandable,
      let rowHeaderView = self.rowHeaderView as? ScrollViewExpandable else {
        return cells
    }
    
    cells.append(contentsOf:
      tableView.visibleSubCells.pairs
        .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow}
        .map { return $1 }
    )
    cells.append(contentsOf:
      rowHeaderView.visibleSubCells.pairs
        .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow}
        .map { return $1 }
    )
    cells.append(contentsOf:
      columnHeaderView.visibleSubCells.pairs
        .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow}
        .map { return $1 }
    )
    cells.append(contentsOf:
      columnHeaderViewRight.visibleSubCells.pairs
        .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow}
        .map { return $1 }
    )
    cells.append(contentsOf:
      cornerView.visibleSubCells.pairs
        .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow}
        .map { return $1 }
    )
    cells.append(contentsOf:
      cornerViewRight.visibleSubCells.pairs
        .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column && $0.key.subrow == indexPath.subrow}
        .map { return $1 }
    )
    return cells
  }
  
  override open func touchesBegan(_ touches: Set<UITouch>, _ event: UIEvent?) {
    guard currentTouch == nil else {
      return
    }
    currentTouch = touches.first
    
    NSObject.cancelPreviousPerformRequests(withTarget: self)
    unhighlightAllSubItems()
    highlightSubItems(on: touches)
    if !allowsMultipleSelection,
      let touch = touches.first, let indexPath = indexPathForSubItem(at: touch.location(in: self)),
      let cell = cellForSubItem(at: indexPath), cell.isUserInteractionEnabled {
      selectedSubIndexPaths.forEach {
        cellsForSubItem(at: $0).forEach { $0.isSelected = false }
      }
      return
    }
    
    currentTouch = nil
    super.touchesBegan(touches, event)
  }
  
  override open func touchesEnded(_ touches: Set<UITouch>, _ event: UIEvent?) {
    super.touchesEnded(touches, event)
    
    guard let touch = touches.first, touch == currentTouch else {
      return
    }
    
    let highlightedItems = highlightedSubIndexPaths
    unhighlightAllSubItems()
    if allowsMultipleSelection,
      let touch = touches.first, let indexPath = indexPathForSubItem(at: touch.location(in: self)),
      selectedSubIndexPaths.contains(indexPath) {
      if expandableDelegate?.spreadsheetView(self, shouldSelectItemAt: indexPath.indexPath, for: indexPath.subrow) ?? true {
        deselectSubItem(at: indexPath)
      }
    } else {
      selectSubItems(on: touches, highlightedItems: highlightedItems)
    }
  }
  
  private func selectSubItem(at indexPath: SubrowIndexPath) {
    let cells = cellsForSubItem(at: indexPath)
    if !cells.isEmpty && expandableDelegate?.spreadsheetView(self, shouldSelectItemAt: indexPath.indexPath, for: indexPath.subrow) ?? true {
      if !allowsMultipleSelection {
        selectedSubIndexPaths.remove(indexPath)
        deselectAllSubItems()
      }
      cells.forEach {
        $0.isSelected = true
      }
      expandableDelegate?.spreadsheetView(self, didSelectItemAt: indexPath.indexPath, for: indexPath.subrow)
      selectedSubIndexPaths.insert(indexPath)
    }
  }
  
  private func deselectSubItem(at indexPath: SubrowIndexPath) {
    let cells = cellsForSubItem(at: indexPath)
    cells.forEach {
      $0.isSelected = false
    }
    expandableDelegate?.spreadsheetView(self, didDeselectItemAt: indexPath.indexPath, for: indexPath.subrow)
    selectedSubIndexPaths.remove(indexPath)
  }
  
  private func selectSubItems(on touches: Set<UITouch>, highlightedItems: Set<SubrowIndexPath>) {
    guard allowsSelection else {
      return
    }
    if let touch = touches.first {
      if let indexPath = indexPathForSubItem(at: touch.location(in: self)), highlightedItems.contains(indexPath) {
        selectSubItem(at: indexPath)
      }
    }
  }
  
  private func deselectAllSubItems() {
    selectedSubIndexPaths.forEach { deselectSubItem(at: $0) }
  }
  
  override open func touchesCancelled(_ touches: Set<UITouch>, _ event: UIEvent?) {
    unhighlightAllSubItems()
    super.touchesCancelled(touches, event)
  }
  
  private func highlightSubItems(on touches: Set<UITouch>) {
    guard allowsSelection else {
      return
    }
    if let touch = touches.first {
      if let indexPath = indexPathForSubItem(at: touch.location(in: self)) {
        guard let cell = cellForSubItem(at: indexPath), cell.isUserInteractionEnabled else {
          return
        }
        if expandableDelegate?.spreadsheetView(self, shouldHighlightItemAt: indexPath.indexPath, for: indexPath.subrow) ?? true {
          highlightedSubIndexPaths.insert(indexPath)
          cellsForSubItem(at: indexPath).forEach {
            $0.isHighlighted = true
          }
          expandableDelegate?.spreadsheetView(self, didHighlightItemAt: indexPath.indexPath, for: indexPath.subrow)
        }
      }
    }
  }
  
  private func unhighlightAllSubItems() {
    highlightedSubIndexPaths.forEach { (indexPath) in
      cellsForSubItem(at: indexPath).forEach {
        $0.isHighlighted = false
      }
      expandableDelegate?.spreadsheetView(self, didUnhighlightItemAt: indexPath.indexPath, for: indexPath.subrow)
    }
    highlightedIndexPaths.removeAll()
  }
 
}

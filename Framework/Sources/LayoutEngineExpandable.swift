//
//  LayoutEngine.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/7/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

final class LayoutEngineExpandable: LayoutEngine {
  
  private let numberOfSubrowsInRow: [Int: Int]
  private let subrowsInRowHeightCache: [Int: [CGFloat]]
  
  var subcellOrigin: CGPoint = .zero
  
  var cellOrigins = [Address: CGPoint]()
  var subcellOrigins = [SubCellAddress: CGPoint]()
  
  var visibleSubCellAddresses = Set<SubCellAddress>()
  
  var horizontalSubGridLayouts = [SubCellAddress: GridLayout]()
  var verticalSubGridLayouts = [SubCellAddress: GridLayout]()
  var visibleSubHorizontalGridAddresses = Set<SubCellAddress>()
  var visibleSubVerticalGridAddresses = Set<SubCellAddress>()
  var visibleSubBorderAddresses = Set<SubCellAddress>()
  
  var subrowsInRowRecords = [Int: [CGFloat]]()
  var spreadsheetExpandableView: SpreadsheetExpandableView?
  var scrollViewExpandable: ScrollViewExpandable?
  
  override init(spreadsheetView: SpreadsheetView, scrollView: ScrollView) {
    if let spreadsheetExpandableView = spreadsheetView as? SpreadsheetExpandableView,
      let properties = spreadsheetExpandableView.layoutProperties as? LayoutPropertiesExpandable,
      let scrollViewExpandable = scrollView as? ScrollViewExpandable {
      numberOfSubrowsInRow = properties.numberOfSubrowsInRow
      subrowsInRowHeightCache = properties.subrowsInRowHeightCache
      subrowsInRowRecords = scrollViewExpandable.subrowsInRowRecords
      self.spreadsheetExpandableView = spreadsheetExpandableView
      self.scrollViewExpandable = scrollViewExpandable
    } else {
      numberOfSubrowsInRow = [Int: Int]()
      subrowsInRowHeightCache = [Int: [CGFloat]]()
      subrowsInRowRecords = [Int: [CGFloat]]()
    }
    super.init(spreadsheetView: spreadsheetView, scrollView: scrollView)
  }
  
  override func layout() {
    guard startColumn != columnCount && startRow != rowCount else {
      return
    }
    
    cellOrigins.removeAll()
    subcellOrigins.removeAll()
    
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

      cellOrigin.y += rowHeightCache[row] + intercellSpacing.height + (subrowsInRowHeightCache[row]?.reduce(0, { (result, height) -> CGFloat in
        var r = result
        r += (spreadsheetExpandableView?.isRowExpanded(at: row) ?? false) ? CGFloat(height + intercellSpacing.height) : CGFloat(0)
        return r
      }) ?? 0)
    }
    
    renderMergedCells()
    renderVerticalGridlines()
    renderHorizontalGridlines()
    renderBorders()
    returnReusableResouces()
  }
  
  override func enumerateColumns(currentRow row: Int, currentRowIndex rowIndex: Int) -> Bool {
    var startColumnIndex = spreadsheetView.findIndex(in: columnRecords, for: visibleRect.origin.x - insets.x)
    cellOrigin.x = insets.x + columnRecords[startColumnIndex] + intercellSpacing.width
    
    var columnIndex = startColumnIndex + startColumn
    var columnStep = 1
    
    while columnIndex < columnCount {
      
      defer {
        columnIndex += columnStep
      }
      
      let column = columnIndex % numberOfColumns
      if circularScrollingOptions.tableStyle.contains(.columnHeaderNotRepeated) && startColumn > 0 && column < frozenColumns {
        continue
      }
      
      let columnWidth = columnWidthCache[columnIndex]
      
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
      
      if spreadsheetExpandableView?.isRowExpanded(at: row) ?? false {
        layoutSubCells(row: row, column: column, rowIndex: rowIndex, columnIndex: columnIndex, rowHeight: rowHeight, columnWidth: columnWidth)
      }
      
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
  
  override public func layoutCell(address: Address, frame: CGRect) {
    guard let dataSource = spreadsheetView.dataSource else {
      return
    }
    
    let gridlines: Gridlines?
    let border: (borders: Borders?, hasBorders: Bool)
    
    if scrollView.visibleCells.contains(address) {
      if let cell = scrollView.visibleCells[address] {
        cell.frame = frame
        cellOrigins[address] = frame.origin
        gridlines = cell.gridlines
        border = (cell.borders, cell.hasBorder)
      } else {
        gridlines = nil
        border = (nil, false)
      }
    } else {
      let indexPath = IndexPath(row: address.rowIndex, column: address.columnIndex)
      
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
      scrollView.bringSubviewToFront(cell)
      scrollView.visibleCells[address] = cell
      
      cellOrigins[address] = frame.origin
    }
    
    if border.hasBorders {
      visibleBorderAddresses.insert(address)
    }
    if let gridlines = gridlines {
      layoutGridlines(address: address, frame: frame, gridlines: gridlines)
    }
  }
  
  private func layoutSubCells(row: Int, column: Int, rowIndex: Int, columnIndex: Int, rowHeight: CGFloat, columnWidth: CGFloat) {
    subcellOrigin = CGPoint(x: cellOrigin.x, y: cellOrigin.y + rowHeight + intercellSpacing.width)
    
    if let numberOfSubrows = numberOfSubrowsInRow[row], numberOfSubrows > 0, let subrowHeights = subrowsInRowHeightCache[row] {
      for subrow in 0...numberOfSubrows - 1 {
        let isRowExpanded = spreadsheetExpandableView?.isRowExpanded(at: row) ?? false
        let subrowOffsetY = isRowExpanded ? subrowHeights[subrow] : 0
        
        guard subcellOrigin.x + columnWidth > visibleRect.minX else {
          subcellOrigin.x += columnWidth + intercellSpacing.width
          continue
        }
        guard subcellOrigin.x <= visibleRect.maxX else {
          subcellOrigin.x += columnWidth + intercellSpacing.width
          return
        }
        guard subcellOrigin.y + subrowOffsetY > visibleRect.minY else {
          subcellOrigin.y += subrowOffsetY + intercellSpacing.width
          continue
        }
        guard subcellOrigin.y <= visibleRect.maxY else {
          return
        }
        
        let address = SubCellAddress(row: row, column: column, rowIndex: rowIndex, columnIndex: columnIndex, subrow: subrow)
        visibleSubCellAddresses.insert(address)
        
        print("layoutSubCells for address: \(address)")
        
        let cellSize = CGSize(width: columnWidth, height: subrowHeights[subrow])
        layoutSubcell(address: address, frame: CGRect(origin: subcellOrigin, size: cellSize))
        
        subcellOrigin.y += subrowOffsetY > 0 ? subrowOffsetY + intercellSpacing.width : 0
      }
      
      //cellOrigin.y += intercellSpacing.width
    }
  }
  
  func expandSubCells(at row: Int) {
    
    cellOrigin = .zero
    enumerateColumns(currentRow: row, currentRowIndex: row)
    
    // views for row sub cells
    var subcellsAtRowViews = [SubCellAddress: Cell]()
    
    var cellAtRowOriginY:CGFloat = 0
    var cellAtRowHeight:CGFloat = 0
    
    for (cellAddress, _) in cellOrigins {
      //Find row all sub cell origins and views
      if cellAddress.row == row, let cellView = scrollViewExpandable?.visibleCells[cellAddress] {
        cellAtRowOriginY = cellView.frame.origin.y
        cellAtRowHeight = cellView.frame.height
        for (subcellAddress, _) in self.subcellOrigins.filter({ $0.key.row == cellAddress.row && $0.key.column == cellAddress.column }) {
          subcellsAtRowViews[subcellAddress] = scrollViewExpandable?.visibleSubCells[subcellAddress]
        }
      }
    }
    
    let orderedSubcellAddresses = subcellsAtRowViews.keys.sorted { (lhs, rhs) -> Bool in
      return lhs.subrow != rhs.subrow ? lhs.subrow < rhs.subrow : lhs.column != rhs.column ? lhs.column < rhs.column : lhs.row < rhs.row
    }
    
    UIView.animate(withDuration: 0.3, animations: {
      
      var expandedSubrowsAtRowHeight:CGFloat = 0
      var currentSubRow = -1
      for subcellAddress in orderedSubcellAddresses {
        if let subcell = subcellsAtRowViews[subcellAddress] {
          let subrowsInRowHeightCache = self.subrowsInRowHeightCache[row] ?? []
          subcell.frame.origin.y = cellAtRowOriginY + cellAtRowHeight + self.intercellSpacing.width + subrowsInRowHeightCache[0..<subcellAddress.subrow].reduce(0, { (result, height) -> CGFloat in
            var r = result
            r += CGFloat(height + self.intercellSpacing.height)
            return r
          })
          if currentSubRow != subcellAddress.subrow {
            expandedSubrowsAtRowHeight += subcell.frame.height + self.intercellSpacing.height
          }
          currentSubRow = subcellAddress.subrow
        }
      }
      
      expandedSubrowsAtRowHeight += self.intercellSpacing.height
      
      for belowRow in (row + 1)...self.rowCount {
        
        var callsCount = 0
        
        for (cellAddress, _) in self.cellOrigins {
          //Find row all sub cell origins and views
          if cellAddress.row == belowRow, let cellView = self.scrollViewExpandable?.visibleCells[cellAddress] {
            
            callsCount += 1
            // views for row sub cells
            var subcellsBelowRowViews = [SubCellAddress: Cell]()
            
            cellView.frame.origin.y += expandedSubrowsAtRowHeight
            self.scrollView.rowRecords[belowRow - self.startRow] = cellView.frame.origin.y
            
            for (subcellAddress, _) in self.subcellOrigins.filter({ $0.key.row == cellAddress.row && $0.key.column == cellAddress.column}) {
              subcellsBelowRowViews[subcellAddress] = self.scrollViewExpandable?.visibleSubCells[subcellAddress]
            }
            
            let orderedSubcellAddresses = subcellsBelowRowViews.keys.sorted { (lhs, rhs) -> Bool in
              return lhs.subrow < rhs.subrow
            }
            
            for subcellAddress in orderedSubcellAddresses {
              if let subcell = subcellsBelowRowViews[subcellAddress] {
                let subrowsInRowHeightCache = self.subrowsInRowHeightCache[belowRow] ?? []
                subcell.frame.origin.y = cellView.frame.origin.y + (self.spreadsheetExpandableView?.isRowExpanded(at: belowRow) ?? false ? (cellView.frame.height + self.intercellSpacing.height) : 0) + subrowsInRowHeightCache[0..<subcellAddress.subrow].reduce(0, { (result, height) -> CGFloat in
                  var r = result
                  r += CGFloat(height + self.intercellSpacing.height)
                  return r
                })
              }
            }
            
          }
          
        }
        
      }
      
      
    }) { _ in
        
    }
    
  }
  
  func collapseSubCells(at row: Int) {
    // views for row sub cells
    var subcellsAtRowViews = [SubCellAddress: Cell]()
  
    var cellAtRowOriginY:CGFloat = 0
    
    for (cellAddress, _) in cellOrigins {
      //Find row all sub cell origins and views
      if cellAddress.row == row, let cellView = scrollViewExpandable?.visibleCells[cellAddress] {
        cellAtRowOriginY = cellView.frame.origin.y
        //scrollView.bringSubviewToFront(cellView)
        for (subcellAddress, _) in self.subcellOrigins.filter({ $0.key.row == cellAddress.row && $0.key.column == cellAddress.column }) {
          subcellsAtRowViews[subcellAddress] = scrollViewExpandable?.visibleSubCells[subcellAddress]
        }
      }
    }
    
    let orderedSubcellAddresses = subcellsAtRowViews.keys.sorted { (lhs, rhs) -> Bool in
      return lhs.subrow < rhs.subrow
    }
    
    var expandedSubrowsAtRowHeight:CGFloat = 0
    var currentSubRow = -1
    
    for subcellAddress in orderedSubcellAddresses {
      if let subcell = subcellsAtRowViews[subcellAddress] {
        //subcell.frame.origin.y = cellAtRowOriginY
        if currentSubRow != subcellAddress.subrow {
          expandedSubrowsAtRowHeight += subcell.frame.height + self.intercellSpacing.height
        }
        currentSubRow = subcellAddress.subrow
      }
    }
    
    expandedSubrowsAtRowHeight += self.intercellSpacing.height
    
    UIView.animate(withDuration: 0.3, animations: {
       
       let nextRow = row + 1
       
       for belowRow in nextRow...self.rowCount {

         for (cellAddress, _) in self.cellOrigins {
           //Find row all sub cell origins and views
          
           if cellAddress.row == belowRow, let cellView = self.scrollViewExpandable?.visibleCells[cellAddress] {
    
             // origins for row sub cells
             var subcellsBelowRowOrigins = [SubCellAddress: CGPoint]()
             // views for row sub cells
             var subcellsBelowRowViews = [SubCellAddress: Cell]()
             
             cellView.frame.origin.y -= expandedSubrowsAtRowHeight
             self.scrollView.rowRecords[belowRow - self.startRow] = cellView.frame.origin.y
             
             for (subcellAddress, subcellOrigin) in self.subcellOrigins.filter({ $0.key.row == cellAddress.row && $0.key.column == cellAddress.column}) {
               subcellsBelowRowOrigins[subcellAddress] = subcellOrigin
               subcellsBelowRowViews[subcellAddress] = self.scrollViewExpandable?.visibleSubCells[subcellAddress]
             }
             
             let orderedSubcellAddresses = subcellsBelowRowViews.keys.sorted { (lhs, rhs) -> Bool in
               return lhs.subrow < rhs.subrow
             }
             
             for subcellAddress in orderedSubcellAddresses {
               if let subcell = subcellsBelowRowViews[subcellAddress], let _ = subcellsBelowRowOrigins[subcellAddress] {
                 let subrowsInRowHeightCache = self.subrowsInRowHeightCache[belowRow] ?? []
                 subcell.frame.origin.y = cellView.frame.origin.y + (self.spreadsheetExpandableView?.isRowExpanded(at: belowRow) ?? false ? (cellView.frame.height + self.intercellSpacing.height) : 0) + subrowsInRowHeightCache[0..<subcellAddress.subrow].reduce(0, { (result, height) -> CGFloat in
                   var r = result
                   r += CGFloat(height + self.intercellSpacing.height)
                   return r
                 })
               }
             }
             
           }
         }
         
       }
      
    }) { _ in
      
      for subcellAddress in orderedSubcellAddresses {
        if let subcell = subcellsAtRowViews[subcellAddress] {
          subcell.frame.origin.y = cellAtRowOriginY
        }
      }
      
      subcellsAtRowViews.values.forEach({ $0.removeFromSuperview() })
      subcellsAtRowViews.keys.forEach({ (address) in
        if let addresses = self.scrollViewExpandable?.visibleSubCells.addresses {
          self.scrollViewExpandable?.visibleSubCells.addresses = addresses.filter({ $0 != address })
        }
        if let pairs = self.scrollViewExpandable?.visibleSubCells.pairs {
          self.scrollViewExpandable?.visibleSubCells.pairs = pairs.filter({ $0.key != address })
        }
      })
    }
  }
  
  private func layoutSubcell(address: SubCellAddress, frame: CGRect) {
    guard let expandableScrollView = scrollView as? ScrollViewExpandable,
      let expandableSpreadSheetView = spreadsheetView as? SpreadsheetExpandableView,
      let dataSource = expandableSpreadSheetView.expandableDataSource else {
      return
    }
    
    let gridlines: Gridlines?
    let border: (borders: Borders?, hasBorders: Bool)
    
//    let indexPath = SubrowIndexPath(indexPath: IndexPath(row: address.rowIndex, column: address.columnIndex), subrow: address.subrow)
//
//    if !expandableSpreadSheetView.isRowExpanded(at: indexPath.row) {
//      return
//    }
    
    if expandableScrollView.visibleSubCells.contains(address) {
      print("expandableScrollView visibleSubCells.contains(address) \(address)")
      if let cell = expandableScrollView.visibleSubCells[address] {
        print("expandableScrollView let cell = expandableScrollView.visibleSubCells[address] \(address)")
        cell.frame = frame
        subcellOrigins[address] = frame.origin
        gridlines = cell.gridlines
        border = (cell.borders, cell.hasBorder)
      } else {
        gridlines = nil
        border = (nil, false)
      }
    } else {
      let indexPath = SubrowIndexPath(indexPath: IndexPath(row: address.rowIndex, column: address.columnIndex), subrow: address.subrow)
      
      let cell = dataSource.spreadsheetView(expandableSpreadSheetView, cellForItemIn: indexPath.subrow, at: indexPath.indexPath) ?? spreadsheetView.dequeueReusableCell(withReuseIdentifier: blankCellReuseIdentifier, for: indexPath.indexPath)
      guard let _ = cell.reuseIdentifier else {
        fatalError("the cell returned from `spreadsheetView(_:cellForItemAt:)` does not have a `reuseIdentifier` - cells must be retrieved by calling `dequeueReusableCell(withReuseIdentifier:for:)`")
      }
      cell.indexPath = indexPath.indexPath
      cell.subrow = indexPath.subrow
      cell.frame = frame
      //cell.isHighlighted = highlightedIndexPaths.contains(indexPath)
      //cell.isSelected = selectedIndexPaths.contains(indexPath)
      
      gridlines = cell.gridlines
      border = (cell.borders, cell.hasBorder)
      
      scrollView.insertSubview(cell, at: 0)
      print("expandableScrollView scrollView.insertSubview(cell, at: 0) \(address)")
      
      expandableScrollView.visibleSubCells[address] = cell
      
      subcellOrigins[address] = frame.origin
    }
    
    if border.hasBorders {
      visibleSubBorderAddresses.insert(address)
    }
    
    if let gridlines = gridlines {
      layoutSubGridlines(address: address, frame: frame, gridlines: gridlines)
    }
  }
  
  func layoutSubGridlines(address: SubCellAddress, frame: CGRect, gridlines: Gridlines) {
    let (topWidth, topColor, topPriority) = extractGridStyle(style: gridlines.top)
    let (bottomWidth, bottomColor, bottomPriority) = extractGridStyle(style: gridlines.bottom)
    let (leftWidth, leftColor, leftPriority) = extractGridStyle(style: gridlines.left)
    let (rightWidth, rightColor, rightPriority) = extractGridStyle(style: gridlines.right)
    
    if let gridLayout = horizontalSubGridLayouts[address] {
      if topPriority > gridLayout.priority {
        horizontalSubGridLayouts[address] = GridLayout(gridWidth: topWidth, gridColor: topColor, origin: frame.origin, length: frame.width, edge: .top(left: leftWidth, right: rightWidth), priority: topPriority)
      }
    } else {
      horizontalSubGridLayouts[address] = GridLayout(gridWidth: topWidth, gridColor: topColor, origin: frame.origin, length: frame.width, edge: .top(left: leftWidth, right: rightWidth), priority: topPriority)
    }
    let underCellAddress = SubCellAddress(row: address.row + 1, column: address.column, rowIndex: address.rowIndex + 1, columnIndex: address.columnIndex)
    if let gridLayout = horizontalSubGridLayouts[underCellAddress] {
      if bottomPriority > gridLayout.priority {
        horizontalSubGridLayouts[underCellAddress] = GridLayout(gridWidth: bottomWidth, gridColor: bottomColor, origin: CGPoint(x: frame.origin.x, y: frame.maxY), length: frame.width, edge: .bottom(left: leftWidth, right: rightWidth), priority: bottomPriority)
      }
    } else {
      horizontalSubGridLayouts[underCellAddress] = GridLayout(gridWidth: bottomWidth, gridColor: bottomColor, origin: CGPoint(x: frame.origin.x, y: frame.maxY), length: frame.width, edge: .bottom(left: leftWidth, right: rightWidth), priority: bottomPriority)
    }
    if let gridLayout = verticalSubGridLayouts[address] {
      if leftPriority > gridLayout.priority {
        verticalSubGridLayouts[address] = GridLayout(gridWidth: leftWidth, gridColor: leftColor, origin: frame.origin, length: frame.height, edge: .left(top: topWidth, bottom: bottomWidth), priority: leftPriority)
      }
    } else {
      verticalSubGridLayouts[address] = GridLayout(gridWidth: leftWidth, gridColor: leftColor, origin: frame.origin, length: frame.height, edge: .left(top: topWidth, bottom: bottomWidth), priority: leftPriority)
    }
    let nextCellAddress = SubCellAddress(row: address.row, column: address.column + 1, rowIndex: address.rowIndex, columnIndex: address.columnIndex + 1)
    if let gridLayout = verticalSubGridLayouts[nextCellAddress] {
      if rightPriority > gridLayout.priority {
        verticalSubGridLayouts[nextCellAddress] = GridLayout(gridWidth: rightWidth, gridColor: rightColor, origin: CGPoint(x: frame.maxX, y: frame.origin.y), length: frame.height, edge: .right(top: topWidth, bottom: bottomWidth), priority: rightPriority)
      }
    } else {
      verticalSubGridLayouts[nextCellAddress] = GridLayout(gridWidth: rightWidth, gridColor: rightColor, origin: CGPoint(x: frame.maxX, y: frame.origin.y), length: frame.height, edge: .right(top: topWidth, bottom: bottomWidth), priority: rightPriority)
    }
  }
  
  override func renderBorders() {
    for address in visibleSubBorderAddresses {
      if let expandableScrollView = scrollView as? ScrollViewExpandable, let cell = expandableScrollView.visibleSubCells[address] {
        if expandableScrollView.visibleSubBorders.contains(address) {
          if let border = expandableScrollView.visibleSubBorders[address] {
            border.borders = cell.borders
            border.frame = cell.frame
            border.setNeedsDisplay()
          }
        } else {
          let border = spreadsheetView.borderReuseQueue.dequeueOrCreate()
          border.borders = cell.borders
          border.frame = cell.frame
          scrollView.addSubview(border)
          expandableScrollView.visibleSubBorders[address] = border
        }
      }
    }
    super.renderBorders()
  }
  
  override func renderHorizontalGridlines() {
    guard let expandableScrollView = scrollView as? ScrollViewExpandable else {
      super.renderHorizontalGridlines()
      return
    }
    
    for (address, gridLayout) in horizontalSubGridLayouts {
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
      
      if expandableScrollView.visibleSubHorizontalGridlines.contains(address) {
        if let gridline = expandableScrollView.visibleSubHorizontalGridlines[address] {
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
        expandableScrollView.visibleSubHorizontalGridlines[address] = gridline
      }
      visibleSubHorizontalGridAddresses.insert(address)
    }
    
    super.renderHorizontalGridlines()
  }
  
  override func renderVerticalGridlines() {
    guard let expandableScrollView = scrollView as? ScrollViewExpandable else {
      super.renderVerticalGridlines()
      return
    }
    
    for (address, gridLayout) in verticalSubGridLayouts {
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
      
      if expandableScrollView.visibleSubVerticalGridlines.contains(address) {
        if let gridline = expandableScrollView.visibleSubVerticalGridlines[address] {
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
        expandableScrollView.visibleSubVerticalGridlines[address] = gridline
      }
      visibleSubVerticalGridAddresses.insert(address)
    }
    
    super.renderVerticalGridlines()
  }
  
  override func returnReusableResouces() {
    guard let expandableScrollView = scrollView as? ScrollViewExpandable else {
      super.returnReusableResouces()
      return
    }
    
    expandableScrollView.visibleSubCells.subtract(visibleSubCellAddresses)
    for address in expandableScrollView.visibleSubCells.addresses {
      if let cell = expandableScrollView.visibleSubCells[address] {
        cell.removeFromSuperview()
        if let reuseIdentifier = cell.reuseIdentifier, let reuseQueue = spreadsheetView.cellReuseQueues[reuseIdentifier] {
          reuseQueue.enqueue(cell)
        }
        expandableScrollView.visibleSubCells[address] = nil
      }
    }
    expandableScrollView.visibleSubCells.addresses = visibleSubCellAddresses
    
    expandableScrollView.visibleSubVerticalGridlines.subtract(visibleSubVerticalGridAddresses)
    for address in expandableScrollView.visibleSubVerticalGridlines.addresses {
      if let gridline = expandableScrollView.visibleSubVerticalGridlines[address] {
        gridline.removeFromSuperlayer()
        spreadsheetView.verticalGridlineReuseQueue.enqueue(gridline)
        expandableScrollView.visibleSubVerticalGridlines[address] = nil
      }
    }
    expandableScrollView.visibleSubVerticalGridlines.addresses = visibleSubVerticalGridAddresses
    
    expandableScrollView.visibleSubHorizontalGridlines.subtract(visibleSubHorizontalGridAddresses)
    for address in expandableScrollView.visibleSubHorizontalGridlines.addresses {
      if let gridline = expandableScrollView.visibleSubHorizontalGridlines[address] {
        gridline.removeFromSuperlayer()
        spreadsheetView.horizontalGridlineReuseQueue.enqueue(gridline)
        expandableScrollView.visibleSubHorizontalGridlines[address] = nil
      }
    }
    expandableScrollView.visibleSubHorizontalGridlines.addresses = visibleSubHorizontalGridAddresses
    
    expandableScrollView.visibleSubBorders.subtract(visibleSubBorderAddresses)
    for address in expandableScrollView.visibleSubBorders.addresses {
      if let border = expandableScrollView.visibleSubBorders[address] {
        border.removeFromSuperview()
        spreadsheetView.borderReuseQueue.enqueue(border)
        expandableScrollView.visibleSubBorders[address] = nil
      }
    }
    expandableScrollView.visibleSubBorders.addresses = visibleSubBorderAddresses
    
    super.returnReusableResouces()
  }
}

public class LayoutPropertiesExpandable: LayoutProperties {
  
  let numberOfSubrowsInRow: [Int: Int]
  let subrowsInRowHeightCache: [Int: [CGFloat]]
  
  init(numberOfColumns: Int = 0, numberOfRows: Int = 0, numberOfSubrowsInRow: [Int: Int] = [:],
       frozenColumns: Int = 0, frozenColumnsRight: Int = 0, frozenRows: Int = 0,
       frozenColumnWidth: CGFloat = 0, frozenRowHeight: CGFloat = 0,
       columnWidth: CGFloat = 0, rowHeight: CGFloat = 0,
       columnWidthCache: [CGFloat] = [], rowHeightCache: [CGFloat] = [], subrowsInRowHeightCache: [Int: [CGFloat]] = [:],
       mergedCells: [CellRange] = [], mergedCellLayouts: [Location: CellRange] = [:]) {
    self.numberOfSubrowsInRow = numberOfSubrowsInRow
    self.subrowsInRowHeightCache = subrowsInRowHeightCache
    super.init(numberOfColumns: numberOfColumns, numberOfRows: numberOfRows,
               frozenColumns: frozenColumns, frozenColumnsRight: frozenColumnsRight, frozenRows: frozenRows,
               frozenColumnWidth: frozenColumnWidth, frozenRowHeight: frozenRowHeight,
               columnWidth: columnWidth, rowHeight: rowHeight,
               columnWidthCache: columnWidthCache, rowHeightCache: rowHeightCache,
               mergedCells: mergedCells, mergedCellLayouts: mergedCellLayouts)
  }
}

public class LayoutAttributesExpandable: LayoutAttributes {
  
  let numberOfSubrowsInRow: [Int: Int]
  
  init(startColumn: Int = 0, startRow: Int = 0,
       numberOfColumns: Int = 0, numberOfRows: Int = 0, columnCount: Int = 0,
       rowCount: Int = 0, insets: CGPoint = .zero, numberOfSubrowsInRow: [Int: Int] = [:]) {
    self.numberOfSubrowsInRow = numberOfSubrowsInRow
    super.init(startColumn: startColumn,
               startRow: startRow,
               numberOfColumns: numberOfColumns,
               numberOfRows: numberOfRows,
               columnCount: columnCount,
               rowCount: rowCount,
               insets: insets)
  }
  
}

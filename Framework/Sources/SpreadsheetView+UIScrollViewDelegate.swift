//
//  SpreadsheetView+UIScrollViewDelegate.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/1/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView: UIScrollViewDelegate {
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollDelegate?.scrollViewDidScroll(scrollView)
    
    rowHeaderView.delegate = nil
    columnHeaderView.delegate = nil
    columnHeaderViewRight.delegate = nil
    tableView.delegate = nil
    
    defer {
      rowHeaderView.delegate = self
      columnHeaderView.delegate = self
      columnHeaderViewRight.delegate = self
      tableView.delegate = self
    }
    
    let leftFoldedColumnsWidth = layoutProperties.columnWidthCache.prefix(upTo: frozenColumns).reduce(0) { $0 + $1 + intercellSpacing.width }
    let rightFoldedColumnsWidth = layoutProperties.columnWidthCache.reversed().prefix(upTo: frozenColumnsRight).reduce(0) { $0 + $1 + intercellSpacing.width }
    
    if tableView.contentOffset.x > (tableView.contentSize.width - self.frame.width + leftFoldedColumnsWidth) && !stickyColumnHeader {
      let offset = tableView.contentOffset.x
      cornerViewRight.frame.origin.x = tableView.contentSize.width - rightFoldedColumnsWidth - offset + leftFoldedColumnsWidth
      columnHeaderViewRight.frame.origin.x = tableView.contentSize.width - rightFoldedColumnsWidth - offset + leftFoldedColumnsWidth
    } else {
      cornerViewRight.frame.origin.x = self.frame.size.width - rightFoldedColumnsWidth
      columnHeaderViewRight.frame.origin.x = self.frame.size.width - rightFoldedColumnsWidth
    }
    
    if (tableView.contentOffset.x) < (tableView.contentSize.width - self.frame.width + leftFoldedColumnsWidth) && !stickyColumnHeader {
      print("cornerViewRight gray divider")
      cornerViewRight.leftBorder?.backgroundColor = self.dividerColor.cgColor
      columnHeaderViewRight.leftBorder?.backgroundColor = self.dividerColor.cgColor
    } else {
       print("cornerViewRight transparent divider")
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
    
    if tableView.contentOffset.x < 0 && !stickyColumnHeader {
      let offset = tableView.contentOffset.x * -1
      cornerView.frame.origin.x = offset
      columnHeaderView.frame.origin.x = offset
    } else {
      cornerView.frame.origin.x = 0
      columnHeaderView.frame.origin.x = 0
    }
    
    if tableView.contentOffset.y < 0 && !stickyRowHeader {
      let offset = tableView.contentOffset.y * -1
      cornerView.frame.origin.y = offset
      cornerViewRight.frame.origin.y = offset
      rowHeaderView.frame.origin.y = offset
    } else {
      cornerView.frame.origin.y = 0
      cornerViewRight.frame.origin.y = 0
      rowHeaderView.frame.origin.y = 0
    }
    
    rowHeaderView.contentOffset.x = tableView.contentOffset.x
    columnHeaderView.contentOffset.y = tableView.contentOffset.y
    columnHeaderViewRight.contentOffset.y = tableView.contentOffset.y
    
    setNeedsLayout()
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    guard let indexPath = pendingSelectionIndexPath else {
      return
    }
    cellsForItem(at: indexPath).forEach { $0.setSelected(true, animated: true) }
    delegate?.spreadsheetView(self, didSelectItemAt: indexPath)
    pendingSelectionIndexPath = nil
  }
  
  @available(iOS 11.0, *)
  public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
    resetScrollViewFrame()
  }
}

//
//  ScrollView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

final class ScrollView: UIScrollView, UIGestureRecognizerDelegate {
    var columnRecords = [CGFloat]()
    var rowRecords = [CGFloat]()

    var visibleCells = ReusableCollection<Cell>()
    var visibleVerticalGridlines = ReusableCollection<Gridline>()
    var visibleHorizontalGridlines = ReusableCollection<Gridline>()
    var visibleBorders = ReusableCollection<Border>()

    typealias TouchHandler = (_ touches: Set<UITouch>, _ event: UIEvent?) -> Void
    var touchesBegan: TouchHandler?
    var touchesEnded: TouchHandler?
    var touchesCancelled: TouchHandler?

    var layoutAttributes = LayoutAttributes(startColumn: 0, startRow: 0, numberOfColumns: 0, numberOfRows: 0, columnCount: 0, rowCount: 0, insets: .zero)
  
    var state = State()
  
    struct State {
        var frame = CGRect.zero
        var contentSize = CGSize.zero
        var contentOffset = CGPoint.zero
    }

    var hasDisplayedContent: Bool {
        return columnRecords.count > 0 || rowRecords.count > 0
    }

    func resetReusableObjects() {
        for cell in visibleCells {
            cell.removeFromSuperview()
        }
        for gridline in visibleVerticalGridlines {
            gridline.removeFromSuperlayer()
        }
        for gridline in visibleHorizontalGridlines {
            gridline.removeFromSuperlayer()
        }
        for border in visibleBorders {
            border.removeFromSuperview()
        }
        visibleCells = ReusableCollection<Cell>()
        visibleVerticalGridlines = ReusableCollection<Gridline>()
        visibleHorizontalGridlines = ReusableCollection<Gridline>()
        visibleBorders = ReusableCollection<Border>()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer
    }

    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        return hasDisplayedContent
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesBegan?(touches, event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesEnded?(touches, event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard hasDisplayedContent else {
            return
        }
        touchesCancelled?(touches, event)
    }
  
    public var topBorder: CALayer? = nil
    public var bottomBorder: CALayer? = nil
    public var leftBorder: CALayer? = nil
    public var rightBorder: CALayer? = nil
  
    func addTopBorder(color: UIColor, thickness: CGFloat) {
      if topBorder != nil && topBorder!.bounds.width == self.state.contentSize.width {
        return
      }
      topBorder?.removeFromSuperlayer()
      topBorder = self.layer.addBorder(edge: .top, color: color, thickness: thickness, length: self.state.contentSize.width)
    }
  
    func addBottomBorder(color: UIColor, thickness: CGFloat) {
      if bottomBorder != nil && bottomBorder!.bounds.width == self.state.contentSize.width {
        return
      }
      bottomBorder?.removeFromSuperlayer()
      bottomBorder = self.layer.addBorder(edge: .bottom, color: color, thickness: thickness, length: self.state.contentSize.width)
    }
  
    func addLeftBorder(color: UIColor, thickness: CGFloat) {
      if leftBorder != nil && leftBorder!.bounds.height == self.state.contentSize.height {
        return
      }
      leftBorder?.removeFromSuperlayer()
      leftBorder = self.layer.addBorder(edge: .left, color: color, thickness: thickness, length: self.state.contentSize.height)
    }
  
    func addRightBorder(color: UIColor, thickness: CGFloat) {
      if rightBorder != nil && rightBorder!.bounds.height == self.state.contentSize.height {
        return
      }
      rightBorder?.removeFromSuperlayer()
      rightBorder = self.layer.addBorder(edge: .right, color: color, thickness: thickness, length: self.state.contentSize.height)
    }
}

extension CALayer {
  
  func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat, length: CGFloat) -> CALayer {
    
    let border = CALayer()
    
    switch edge {
    case .top:
      border.frame = CGRect(x: 0, y: 0, width: length, height: thickness)
    case .bottom:
      border.frame = CGRect(x: 0, y: frame.height - thickness, width: length, height: thickness)
    case .left:
      border.frame = CGRect(x: 0, y: 0, width: thickness, height: length)
    case .right:
      border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: length)
    default:
      break
    }
    
    border.backgroundColor = color.cgColor
    border.zPosition = 300
    
    addSublayer(border)
    
    return border
  }
}

//
//  Spreadsheet.swift
//  Calc
//
//  Created by Kishikawa Katsumi on 2017/06/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

public class Spreadsheet: UIView, SpreadsheetViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    public var delegate: SpreadsheetDelegate?

    private let spreadsheetDataSource = SpreadsheetDataSource()

    private let spreadsheetView = SpreadsheetView()
    private let selectionView = SelectionView()

    private var previousHeaderHandleLocation: CGPoint = .zero
    private var startIndexPath = IndexPath(row: 0, column: 0)
    private var selectionRange: SelectionRange?
    private var selectedCellRange: CellRange?

    private var isRowSelected = false {
        didSet {
            selectionView.isRowSelectionEnabled = isRowSelected
        }
    }
    private var isColumnSelected = false {
        didSet {
            selectionView.isColumnSelectionEnabled = isColumnSelected
        }
    }
    private var isLeftHandleDragging = false
    private var isRightHandleDragging = false
    private var isRowHeaderHandleDragging = false {
        didSet {
            isColumnSelected = isRowHeaderHandleDragging
        }
    }
    private var isColumnHeaderHandleDragging = false {
        didSet {
            isRowSelected = isColumnHeaderHandleDragging
        }
    }

    private var isCellDragging = false
    private var previousLocation: CGPoint = .zero
    private var previousIndexPath = IndexPath(row: 0, column: 0)
    private var destinationSelectionRange: SelectionRange?
    private var snapshotView = UIView()
    private var sourceView = UIView()

    private let textField = UITextField()
    private var editingIndexPath: IndexPath?

    private var isMenuVisible: Bool {
        let menuController = UIMenuController.shared
        return menuController.isMenuVisible
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        spreadsheetView.frame = bounds
        spreadsheetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let hairline = 1 / UIScreen.main.scale
        spreadsheetView.intercellSpacing = CGSize(width: hairline, height: hairline)
        spreadsheetView.gridStyle = .solid(width: hairline, color: UIColor(white: 0.6, alpha: 1))
        spreadsheetView.dataSource = spreadsheetDataSource
        spreadsheetView.delegate = self
        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        spreadsheetView.scrollView.delegate = self
        addSubview(spreadsheetView)

        selectionView.isHidden = true
        spreadsheetView.addSubview(selectionView)

        sourceView.backgroundColor = UIColor(white: 0.85, alpha: 1)
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 12)

        let dragGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(spreadsheetDragged(_:)))
        dragGestureRecognizer.delegate = self
        dragGestureRecognizer.minimumPressDuration = CFTimeInterval.leastNonzeroMagnitude
        spreadsheetView.addGestureRecognizer(dragGestureRecognizer)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed(_:)))
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 0.3
        spreadsheetView.addGestureRecognizer(longPressGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        spreadsheetView.addGestureRecognizer(tapGestureRecognizer)

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellDoubleTapped(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        spreadsheetView.addGestureRecognizer(doubleTapGestureRecognizer)
    }

    func spreadsheetDragged(_ gestureRecognizer: UILongPressGestureRecognizer) {
        print("spreadsheetDragged: \(gestureRecognizer.state.rawValue)")
        let location = gestureRecognizer.location(in: spreadsheetView)
        switch gestureRecognizer.state {
        case .began:
            hideMenu()
            if isColumnSelected || isRowSelected {
                if selectionView.convert(CGRect(x: selectionView.bounds.maxX - 20, y: 0, width: 30, height: 30), to: spreadsheetView).contains(location) {
                    spreadsheetView.isScrollEnabled = false
                    isRowHeaderHandleDragging = true
                }
                if selectionView.convert(CGRect(x: 0, y: selectionView.bounds.maxY - 20, width: 60, height: 30), to: spreadsheetView).contains(location) {
                    spreadsheetView.isScrollEnabled = false
                    isColumnHeaderHandleDragging = true
                }
                previousHeaderHandleLocation = location
            } else {
                if selectionView.convert(CGRect(x: -20, y: -20, width: 40, height: 40), to: spreadsheetView).contains(location) {
                    spreadsheetView.isScrollEnabled = false
                    isLeftHandleDragging = true
                    startIndexPath = selectionRange!.to
                }
                if selectionView.convert(CGRect(x: selectionView.bounds.maxX - 20, y: selectionView.bounds.maxY - 20, width: 40, height: 40), to: spreadsheetView).contains(location) {
                    spreadsheetView.isScrollEnabled = false
                    isRightHandleDragging = true
                    startIndexPath = selectionRange!.from
                }
            }
        case .changed:
            if isRowHeaderHandleDragging {
                let column = selectionRange!.from.column
                let width = spreadsheetDataSource.width(for: column)
                spreadsheetDataSource.set(width: width - (previousHeaderHandleLocation.x - location.x), for: column)
                spreadsheetView.reloadData()
                updateSelectionView(selectionRange: selectionRange!)
                previousHeaderHandleLocation = location
            }
            if isColumnHeaderHandleDragging {
                let row = selectionRange!.from.row
                let height = spreadsheetDataSource.height(for: row)
                spreadsheetDataSource.set(height: height - (previousHeaderHandleLocation.y - location.y), for: row)
                spreadsheetView.reloadData()
                updateSelectionView(selectionRange: selectionRange!)
                previousHeaderHandleLocation = location
            }
            if isLeftHandleDragging {
                if let indexPath = spreadsheetView.indexPathForItem(at: CGPoint(x: location.x + 4, y: location.y + 4)) {
                    self.selectionRange = SelectionRange(from: indexPath, to: startIndexPath)
                    self.selectionRange = self.selectionRange?.normalizedSelectionRange
                    self.selectionRange = self.selectionRange?.expandSelectionRange(mergedCells: spreadsheetDataSource.mergedCellStore.mergedCells)
                    updateSelectionView(selectionRange: self.selectionRange!)
                }
            }
            if isRightHandleDragging {
                if let indexPath = spreadsheetView.indexPathForItem(at: CGPoint(x: location.x - 4, y: location.y - 4)) {
                    self.selectionRange = SelectionRange(from: startIndexPath, to: indexPath)
                    self.selectionRange = self.selectionRange?.normalizedSelectionRange
                    self.selectionRange = self.selectionRange?.expandSelectionRange(mergedCells: spreadsheetDataSource.mergedCellStore.mergedCells)
                    updateSelectionView(selectionRange: self.selectionRange!)
                }
            }
        case .ended:
            if isLeftHandleDragging || isRightHandleDragging {
                if let selectionRange = selectionRange {
                    showMenu()
                    updateSelectedCellRange(selectionRange: selectionRange)
                }
            }
            spreadsheetView.isScrollEnabled = true
            isRowHeaderHandleDragging = false
            isColumnHeaderHandleDragging = false
            isLeftHandleDragging = false
            isRightHandleDragging = false
            previousHeaderHandleLocation = .zero
        default:
            spreadsheetView.isScrollEnabled = true
            isRowHeaderHandleDragging = false
            isColumnHeaderHandleDragging = false
            isLeftHandleDragging = false
            isRightHandleDragging = false
            previousHeaderHandleLocation = .zero
        }
    }

    func cellLongPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        print("cellLongPressed")
        guard !isLeftHandleDragging && !isRightHandleDragging
            && !isRowHeaderHandleDragging && !isColumnHeaderHandleDragging else {
            return
        }

        let location = gestureRecognizer.location(in: spreadsheetView)

        switch gestureRecognizer.state {
        case .began:
            hideMenu()
            spreadsheetView.isScrollEnabled = false

            if let indexPath = spreadsheetView.indexPathForItem(at: location) {
                if let selectedCellRange = selectedCellRange, selectedCellRange.contains(indexPath) {
                    destinationSelectionRange = selectionRange

                    selectionView.leftCornerHandle.isHidden = true
                    selectionView.rightCornerHandle.isHidden = true
                    selectionView.isHidden = true

                    let frame = selectionView.frame.insetBy(dx: 4, dy: 4)
                    sourceView.frame = frame
                    spreadsheetView.insertSubview(sourceView, belowSubview: selectionView)

                    snapshotView = spreadsheetView.resizableSnapshotView(from: frame, afterScreenUpdates: false, withCapInsets: .zero)!
                    snapshotView.frame = frame
                    spreadsheetView.addSubview(snapshotView)

                    previousLocation = location
                    previousIndexPath = indexPath
                    isCellDragging = true

                    UIView.animate(withDuration: CATransaction.animationDuration(), delay: 0, options: .curveEaseOut, animations: {
                        self.snapshotView.frame.origin.y -= 8
                        self.snapshotView.alpha = 0.5
                        self.snapshotView.layer.shadowColor = UIColor.black.cgColor
                        self.snapshotView.layer.shadowOffset = .zero
                        self.snapshotView.layer.shadowOpacity = 0.5
                        self.snapshotView.layer.shadowRadius = 4
                    }, completion: nil)
                } else {
                    startIndexPath = indexPath
                    selectionRange = SelectionRange(from: indexPath, to: indexPath)
                    updateSelectionView(selectionRange: selectionRange!)
                    updateSelectedCellRange(selectionRange: selectionRange!)
                    selectionView.isHidden = false
                }
            }
        case .changed:
            if isCellDragging {
                if let indexPath = spreadsheetView.indexPathForItem(at: location), let selectedCellRange = selectedCellRange {
                    let diffColumn = previousIndexPath.column - indexPath.column
                    let diffRow = previousIndexPath.row - indexPath.row

                    var fromRow = selectedCellRange.from.row - diffRow
                    var fromColumn = selectedCellRange.from.column - diffColumn
                    var toRow = selectedCellRange.to.row - diffRow
                    var toColumn = selectedCellRange.to.column - diffColumn
                    if fromRow < 0 || toRow > spreadsheetView.numberOfRows || fromColumn < 0 || toColumn > spreadsheetView.numberOfColumns {
                        fromRow = destinationSelectionRange!.from.row
                        fromColumn = destinationSelectionRange!.from.column
                        toRow = destinationSelectionRange!.to.row
                        toColumn = destinationSelectionRange!.to.column
                    }

                    destinationSelectionRange = SelectionRange(from: IndexPath(row: fromRow, column: fromColumn), to: IndexPath(row: toRow, column: toColumn))
                    updateSelectionView(selectionRange: destinationSelectionRange!)
                    selectionView.isHidden = false
                }
                let diffX = previousLocation.x - location.x
                let diffY = previousLocation.y - location.y
                let center = snapshotView.center
                snapshotView.center = CGPoint(x: center.x - diffX, y: center.y - diffY)
                previousLocation = location
            } else if let indexPath = spreadsheetView.indexPathForItem(at: location) {
                self.selectionRange = SelectionRange(from: startIndexPath, to: indexPath)
                self.selectionRange = self.selectionRange?.normalizedSelectionRange
                self.selectionRange = self.selectionRange?.expandSelectionRange(mergedCells: spreadsheetDataSource.mergedCellStore.mergedCells)
                updateSelectionView(selectionRange: self.selectionRange!)
            }
        case .ended:
            spreadsheetView.isScrollEnabled = true

            if isCellDragging {
                var sourceData = [Int: String]()
                var index = 0
                if let selectionRange = selectionRange {
                    for column in selectionRange.from.column...selectionRange.to.column {
                        for row in selectionRange.from.row...selectionRange.to.row {
                            let indexPath = IndexPath(row: row, column: column)
                            sourceData[index] = spreadsheetDataSource.data[indexPath]
                            spreadsheetDataSource.data[indexPath] = nil
                            index += 1
                        }
                    }
                }
                index = 0
                if let selectionRange = destinationSelectionRange {
                    for column in selectionRange.from.column...selectionRange.to.column {
                        for row in selectionRange.from.row...selectionRange.to.row {
                            let indexPath = IndexPath(row: row, column: column)
                            spreadsheetDataSource.data[indexPath] = sourceData[index]
                            index += 1
                        }
                    }
                }
                spreadsheetView.reloadData()

                UIView.animate(withDuration: CATransaction.animationDuration(), delay: 0, options: .curveEaseOut, animations: {
                    self.snapshotView.frame = self.selectionView.frame.insetBy(dx: 4, dy: 4)
                    self.snapshotView.alpha = 1
                    self.snapshotView.layer.shadowOpacity = 0
                    self.snapshotView.layer.shadowRadius = 0
                    self.sourceView.alpha = 0
                }, completion: { (finished) in
                    self.snapshotView.removeFromSuperview()
                    self.sourceView.removeFromSuperview()
                    self.sourceView.alpha = 1
                    self.isCellDragging = false
                })

                selectionRange = destinationSelectionRange
                updateSelectedCellRange(selectionRange: selectionRange!)

                selectionView.leftCornerHandle.isHidden = false
                selectionView.rightCornerHandle.isHidden = false
                selectionView.isHidden = false
            } else {
                if let selectionRange = selectionRange {
                    updateSelectedCellRange(selectionRange: selectionRange)
                    showMenu()
                }
            }
        default:
            spreadsheetView.isScrollEnabled = true
            isCellDragging = false
            selectionView.leftCornerHandle.isHidden = false
            selectionView.rightCornerHandle.isHidden = false
            snapshotView.removeFromSuperview()
        }
    }

    func cellTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        print("cellTapped")
        guard !isCellDragging else {
            return
        }
        let location = gestureRecognizer.location(in: spreadsheetView)
        if let indexPath = spreadsheetView.indexPathForItem(at: location) {
            if indexPath.column == 0 && indexPath.row > 0 {
                isRowSelected = true
                selectionRange = SelectionRange(from: indexPath, to: IndexPath(row: indexPath.row, column: spreadsheetDataSource.numberOfColumns - 1))
                updateSelectionView(selectionRange: selectionRange!)
                updateSelectedCellRange(selectionRange: selectionRange!)
                selectionView.isHidden = false
            }
            if indexPath.column > 0 && indexPath.row == 0 {
                isColumnSelected = true
                selectionRange = SelectionRange(from: indexPath, to: IndexPath(row: spreadsheetDataSource.numberOfRows - 1, column: indexPath.column))
                updateSelectionView(selectionRange: selectionRange!)
                updateSelectedCellRange(selectionRange: selectionRange!)
                selectionView.isHidden = false
            }
            if let range = selectionRange {
                let cellRange = CellRange(from: range.from, to: range.to)
                if cellRange.contains(indexPath) {
                    if isMenuVisible {
                        hideMenu()
                    } else {
                        showMenu()
                    }
                } else {
                    hideMenu()
                    selectionRange = SelectionRange(from: indexPath, to: indexPath)
                    updateSelectionView(selectionRange: selectionRange!)
                    updateSelectedCellRange(selectionRange: selectionRange!)
                    selectionView.isHidden = false

                    if let editingIndexPath = editingIndexPath {
                        spreadsheetDataSource.data[editingIndexPath] = textField.text ?? ""
                        spreadsheetView.reloadData()

                        textField.frame = selectionView.frame.insetBy(dx: 6, dy: 6)
                        textField.text = spreadsheetDataSource.data[indexPath]
                        delegate?.spreadsheet(self, textDidBeginEditingAt: indexPath)

                        self.editingIndexPath = indexPath
                    }
                }
            } else {
                hideMenu()
                selectionRange = SelectionRange(from: indexPath, to: indexPath)
                updateSelectionView(selectionRange: selectionRange!)
                updateSelectedCellRange(selectionRange: selectionRange!)
                selectionView.isHidden = false
            }
            selectionView.isHidden = false
        }
    }

    func cellDoubleTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        print("cellDoubleTapped")
        let location = gestureRecognizer.location(in: spreadsheetView)
        if let indexPath = spreadsheetView.indexPathForItem(at: location) {
            selectionRange = SelectionRange(from: indexPath, to: indexPath)
            updateSelectionView(selectionRange: selectionRange!)
            updateSelectedCellRange(selectionRange: selectionRange!)

            if delegate?.spreadsheet(self, textShouldBeginEditingAt: indexPath) ?? true {
                if let cell = spreadsheetView.cellForItem(at: indexPath) as? TextCell {
                    cell.text = ""
                }

                textField.frame = selectionView.frame.insetBy(dx: 6, dy: 6)
                textField.text = spreadsheetDataSource.data[indexPath]
                spreadsheetView.addSubview(textField)
                textField.becomeFirstResponder()
                delegate?.spreadsheet(self, textDidBeginEditingAt: indexPath)

                editingIndexPath = indexPath
            }
        }
    }

    func cellAction(_ sender: Any?) {
        guard let delegate = delegate else {
            return
        }
        if let cellRange = selectedCellRange {
            let intersection = spreadsheetDataSource.mergedCellStore.intersection(cellRange: cellRange)
            delegate.spreadsheet(self, performCellAction: cellRange, intersection: intersection)
        }
    }

    public func mergeCells(cellRange: CellRange) {
        spreadsheetDataSource.mergeCells(cellRange: cellRange)
        spreadsheetView.reloadData()
    }

    public func unmergeCell(cellRange: CellRange) {
        spreadsheetDataSource.unmergeCell(cellRange: cellRange)
        spreadsheetView.reloadData()
    }

    public override func paste(_ sender: Any?) {

    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(paste(_:)) || action == #selector(cellAction(_:))
    }

    public override var canBecomeFirstResponder: Bool {
        return true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let selectionRange = selectionRange {
            updateSelectionView(selectionRange: selectionRange)
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let editingIndexPath = editingIndexPath {
            spreadsheetDataSource.data[editingIndexPath] = textField.text ?? ""
            spreadsheetView.reloadData()
        }
        textField.removeFromSuperview()
        editingIndexPath = nil
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    private func updateSelectionView(selectionRange: SelectionRange) {
        let fromRect = spreadsheetView.rectForItem(at: selectionRange.from)
        let toRect = spreadsheetView.rectForItem(at: selectionRange.to)
        if selectionRange.from.column < spreadsheetDataSource.frozenColumns && spreadsheetView.contentOffset.x > 0 {
            selectionView.frame.origin = CGPoint(x: spreadsheetView.contentOffset.x + spreadsheetView.contentInset.left,
                                                 y: fromRect.origin.y + spreadsheetView.contentInset.top)
            selectionView.frame.size = CGSize(width: toRect.maxX - fromRect.minX - spreadsheetView.contentOffset.x , height: toRect.maxY - fromRect.minY)
        } else {
            selectionView.frame.origin = CGPoint(x: fromRect.origin.x + spreadsheetView.contentInset.left,
                                                 y: fromRect.origin.y + spreadsheetView.contentInset.top)
            selectionView.frame.size = CGSize(width: toRect.maxX - fromRect.minX, height: toRect.maxY - fromRect.minY)
        }
        selectionView.frame = selectionView.frame.insetBy(dx: -4, dy: -4)
    }

    private func updateSelectedCellRange(selectionRange: SelectionRange) {
        selectedCellRange = CellRange(from: selectionRange.from, to: selectionRange.to)
    }

    private func showMenu() {
        becomeFirstResponder()
        let menuController = UIMenuController.shared
        menuController.menuItems = [UIMenuItem(title: "Cell Actions...", action: #selector(cellAction(_:)))]
        menuController.setTargetRect(selectionView.frame, in: spreadsheetView)
        menuController.setMenuVisible(true, animated: true)
    }

    private func hideMenu() {
        let menuController = UIMenuController.shared
        menuController.setMenuVisible(false, animated: true)
        resignFirstResponder()
    }
}

struct SelectionRange: Sequence {
    let from: IndexPath
    let to: IndexPath

    var normalizedSelectionRange: SelectionRange {
        if to.column < from.column && to.row < from.row {
            return SelectionRange(from: to, to: from)
        } else if to.column < from.column {
            return SelectionRange(from: IndexPath(row: from.row, column: to.column), to: IndexPath(row: to.row, column: from.column))
        } else  if to.row < from.row {
            return SelectionRange(from: IndexPath(row: to.row, column: from.column), to: IndexPath(row: from.row, column: to.column))
        } else {
            return SelectionRange(from: from, to: to)
        }
    }

    func expandSelectionRange(mergedCells: [IndexPath: CellRange]) -> SelectionRange {
        var from = (row: self.from.row, column: self.from.column)
        var to = (row: self.to.row, column: self.to.column)
        for indexPath in self {
            if let mergedCell = mergedCells[indexPath] {
                if from.column > mergedCell.from.column {
                    from.column = mergedCell.from.column
                }
                if from.row > mergedCell.from.row {
                    from.row = mergedCell.from.row
                }
                if to.column < mergedCell.to.column {
                    to.column = mergedCell.to.column
                }
                if to.row < mergedCell.to.row {
                    to.row = mergedCell.to.row
                }
            }
        }
        return SelectionRange(from: IndexPath(row: from.row, column: from.column), to: IndexPath(row: to.row, column: to.column))
    }

    public typealias Iterator = SelectionRangeIterator

    public func makeIterator() -> SelectionRangeIterator {
        return SelectionRangeIterator(selectionRange: self)
    }

    struct SelectionRangeIterator: IteratorProtocol {
        public typealias Element = IndexPath

        private let selectionRange: SelectionRange
        private var column: Int
        private var row: Int

        init(selectionRange: SelectionRange) {
            self.selectionRange = selectionRange
            column = selectionRange.from.column
            row = selectionRange.from.row
        }

        public mutating func next() -> IndexPath? {
            if column > selectionRange.to.column {
                column = 0
                row += 1
                if row > selectionRange.to.row {
                    return nil
                }
            }
            let indexPath = IndexPath(row: row, column: column)
            column += 1
            return indexPath
        }
    }
}

class MergedCellStore {
    var mergedCells = [IndexPath: CellRange]()

    subscript(_ indexPath: IndexPath) -> CellRange? {
        get {
            return mergedCells[indexPath]
        }
        set {
            return mergedCells[indexPath] = newValue
        }
    }

    func intersection(cellRange: CellRange) -> CellRange? {
        for indexPath in cellRange {
            if let existingMergedCell = self[indexPath] {
                if let intersection = cellRange.intersection(existingMergedCell) {
                    return intersection
                }
            }
        }
        return nil
    }
}

extension CellRange {
    func isEqual(cellRange: CellRange) -> Bool {
        return self == cellRange && self.to.column == cellRange.to.column && self.to.row == cellRange.to.row
    }
}

extension CellRange: Sequence {
    public typealias Iterator = CellRangeIterator

    public func makeIterator() -> CellRangeIterator {
        return CellRangeIterator(cellRange: self)
    }
}

public struct CellRangeIterator: IteratorProtocol {
    public typealias Element = IndexPath

    private let cellRange: CellRange
    private var column: Int
    private var row: Int

    init(cellRange: CellRange) {
        self.cellRange = cellRange
        column = cellRange.from.column
        row = cellRange.from.row
    }

    public mutating func next() -> IndexPath? {
        if column > cellRange.to.column {
            column = 0
            row += 1
            if row > cellRange.to.row {
                return nil
            }
        }
        let indexPath = IndexPath(row: row, column: column)
        column += 1
        return indexPath
    }
}

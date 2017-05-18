//
//  SpreadsheetView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

public class SpreadsheetView: UIView {
    public weak var dataSource: SpreadsheetViewDataSource? {
        didSet {
            resetTouchHandlers(to: [tableView, columnHeaderView, rowHeaderView, cornerView])
            reloadData()
        }
    }
    public weak var delegate: SpreadsheetViewDelegate?

    public var intercellSpacing = CGSize(width: 1, height: 1)
    public var gridStyle: GridStyle = .solid(width: 1, color: .lightGray)

    public var allowsSelection = true {
        didSet {
            if !allowsSelection {
                allowsMultipleSelection = false
            }
        }
    }
    public var allowsMultipleSelection = false {
        didSet {
            if allowsMultipleSelection {
                allowsSelection = true
            }
        }
    }

    public var showsVerticalScrollIndicator = true {
        didSet {
            overlayView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
    }
    public var showsHorizontalScrollIndicator = true {
        didSet {
            overlayView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
    }
    public var scrollsToTop: Bool = true {
        didSet {
            tableView.scrollsToTop = scrollsToTop
        }
    }

    public var circularScrolling: CircularScrollingConfiguration = CircularScrolling.Configuration.none {
        didSet {
            circularScrollingOptions = circularScrolling.options
            if circularScrollingOptions.direction.contains(.horizontally) {
                showsHorizontalScrollIndicator = false
            }
            if circularScrollingOptions.direction.contains(.vertically) {
                showsVerticalScrollIndicator = false
                scrollsToTop = false
            }
        }
    }
    var circularScrollingOptions = CircularScrolling.Configuration.none.options
    var circularScrollScalingFactor: (horizontal: Int, vertical: Int) = (1, 1)
    var centerOffset = CGPoint.zero

    public var backgroundView: UIView? {
        willSet {
            backgroundView?.removeFromSuperview()
        }
        didSet {
            if let backgroundView = backgroundView {
                backgroundView.frame = bounds
                backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                insertSubview(backgroundView, at: 0)
            }
        }
    }

    public var visibleCells: [Cell] {
        let cells: [Cell] = Array(columnHeaderView.visibleCells) + Array(rowHeaderView.visibleCells)
            + Array(cornerView.visibleCells) + Array(tableView.visibleCells)
        return cells.sorted()
    }

    public var indexPathsForVisibleItems: [IndexPath] {
        return visibleCells.map { $0.indexPath }
    }

    public var indexPathForSelectedItem: IndexPath? {
        return Array(selectedIndexPaths).sorted().first
    }

    public var indexPathsForSelectedItems: [IndexPath] {
        return Array(selectedIndexPaths).sorted()
    }

    public var isDirectionalLockEnabled = false {
        didSet {
            tableView.isDirectionalLockEnabled = isDirectionalLockEnabled
        }
    }

    public var bounces: Bool {
        get {
            return tableView.bounces
        }
        set {
            tableView.bounces = newValue
        }
    }
    public var alwaysBounceVertical: Bool {
        get {
            return tableView.alwaysBounceVertical
        }
        set {
            tableView.alwaysBounceVertical = newValue
        }
    }
    public var alwaysBounceHorizontal: Bool {
        get {
            return tableView.alwaysBounceHorizontal
        }
        set {
            tableView.alwaysBounceHorizontal = newValue
        }
    }

    public var isPagingEnabled: Bool {
        get {
            return tableView.isPagingEnabled
        }
        set {
            tableView.isPagingEnabled = newValue
        }
    }
    public var isScrollEnabled: Bool {
        get {
            return tableView.isScrollEnabled
        }
        set {
            tableView.isScrollEnabled = newValue
        }
    }

    public var indicatorStyle: UIScrollViewIndicatorStyle {
        get {
            return overlayView.indicatorStyle
        }
        set {
            overlayView.indicatorStyle = newValue
        }
    }

    public var decelerationRate: CGFloat {
        get {
            return tableView.decelerationRate
        }
        set {
            tableView.decelerationRate = newValue
        }
    }

    public var numberOfColumns: Int {
        return layoutProperties.numberOfColumns
    }
    public var numberOfRows: Int {
        return layoutProperties.numberOfRows
    }
    public var frozenColumns: Int {
        return layoutProperties.frozenColumns
    }
    public var frozenRows: Int {
        return layoutProperties.frozenRows
    }
    public var mergedCells: [CellRange] {
        return layoutProperties.mergedCells
    }
    var layoutProperties = LayoutProperties()

    let rootView = UIScrollView()
    let overlayView = UIScrollView()

    let rowHeaderView = ScrollView()
    let columnHeaderView = ScrollView()
    let cornerView = ScrollView()
    let tableView = ScrollView()

    var cellClasses = [String: Cell.Type]()
    var cellNibs = [String: UINib]()
    var cellReuseQueues = [String: ReuseQueue<Cell>]()
    let blankCellReuseIdentifier = UUID().uuidString

    var horizontalGridlineReuseQueue = ReuseQueue<Gridline>()
    var verticalGridlineReuseQueue = ReuseQueue<Gridline>()
    var borderReuseQueue = ReuseQueue<Border>()

    var highlightedIndexPaths = Set<IndexPath>()
    var selectedIndexPaths = Set<IndexPath>()
    var pendingSelectionIndexPath: IndexPath?
    var currentTouch: UITouch?

    var needsReload = true
    var isAutomaticContentOffsetAdjustmentEnabled = true

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        rootView.frame = bounds
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootView.showsHorizontalScrollIndicator = false
        rootView.showsVerticalScrollIndicator = false
        addSubview(rootView)

        tableView.frame = bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.autoresizesSubviews = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self

        columnHeaderView.frame = bounds
        columnHeaderView.frame.size.width = 0
        columnHeaderView.autoresizingMask = [.flexibleHeight]
        columnHeaderView.autoresizesSubviews = false
        columnHeaderView.showsHorizontalScrollIndicator = false
        columnHeaderView.showsVerticalScrollIndicator = false
        columnHeaderView.isHidden = true
        columnHeaderView.delegate = self

        rowHeaderView.frame = bounds
        rowHeaderView.frame.size.height = 0
        rowHeaderView.autoresizingMask = [.flexibleWidth]
        rowHeaderView.autoresizesSubviews = false
        rowHeaderView.showsHorizontalScrollIndicator = false
        rowHeaderView.showsVerticalScrollIndicator = false
        rowHeaderView.isHidden = true
        rowHeaderView.delegate = self

        cornerView.autoresizesSubviews = false
        cornerView.isHidden = true
        cornerView.delegate = self

        overlayView.frame = bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.autoresizesSubviews = false
        overlayView.isUserInteractionEnabled = false

        rootView.addSubview(tableView)
        rootView.addSubview(columnHeaderView)
        rootView.addSubview(rowHeaderView)
        rootView.addSubview(cornerView)
        addSubview(overlayView)

        [tableView, columnHeaderView, rowHeaderView, cornerView, overlayView].forEach {
            addGestureRecognizer($0.panGestureRecognizer)
        }
    }

    @objc(registerClass:forCellWithReuseIdentifier:)
    public func register(_ cellClass: Cell.Type, forCellWithReuseIdentifier identifier: String) {
        cellClasses[identifier] = cellClass
    }

    @objc(registerNib:forCellWithReuseIdentifier:)
    public func register(_ nib: UINib, forCellWithReuseIdentifier identifier: String) {
        cellNibs[identifier] = nib
    }

    public func reloadData() {
        setNeedsReload()
    }

    func reloadDataIfNeeded() {
        if needsReload {
            refreshData()
        }
    }

    func setNeedsReload() {
        needsReload = true
        setNeedsLayout()
    }

    func refreshData() {
        layoutProperties = resetLayoutProperties()
        circularScrollScalingFactor =  determineCircularScrollScalingFactor()
        centerOffset = calculateCenterOffset()

        cornerView.layoutAttributes = layoutAttributeForCornerView()
        columnHeaderView.layoutAttributes = layoutAttributeForColumnHeaderView()
        rowHeaderView.layoutAttributes = layoutAttributeForRowHeaderView()
        tableView.layoutAttributes = layoutAttributeForTableView()

        cornerView.resetReusableObjects()
        columnHeaderView.resetReusableObjects()
        rowHeaderView.resetReusableObjects()
        tableView.resetReusableObjects()

        resetContentSize(of: cornerView)
        resetContentSize(of: columnHeaderView)
        resetContentSize(of: rowHeaderView)
        resetContentSize(of: tableView)

        cornerView.frame.size = cornerView.contentSize
        columnHeaderView.frame.size.width = columnHeaderView.contentSize.width
        rowHeaderView.frame.size.height = rowHeaderView.contentSize.height
    }

    public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> Cell {
        if let reuseQueue = cellReuseQueues[identifier] {
            if let cell = reuseQueue.dequeue() {
                cell.prepareForReuse()

                return cell
            }
        } else {
            let reuseQueue = ReuseQueue<Cell>()
            cellReuseQueues[identifier] = reuseQueue
        }
        if identifier == blankCellReuseIdentifier {
            let cell = BlankCell()
            cell.reuseIdentifier = identifier

            return cell
        }
        if let clazz = cellClasses[identifier] {
            let cell = clazz.init()
            cell.reuseIdentifier = identifier

            return cell
        }
        if let nib = cellNibs[identifier] {
            if let cell = nib.instantiate(withOwner: nil, options: nil).first as? Cell {
                cell.reuseIdentifier = identifier

                return cell
            }
        }
        fatalError("could not dequeue a view with identifier cell - must register a nib or a class for the identifier")
    }

    private func resetTouchHandlers(to scrollViews: [ScrollView]) {
        scrollViews.forEach {
            if let _ = dataSource {
                $0.touchesBegan = { [weak self] (touches, event) in
                    self?.touchesBegan(touches, event)
                }
                $0.touchesEnded = { [weak self] (touches, event) in
                    self?.touchesEnded(touches, event)
                }
                $0.touchesCancelled = { [weak self] (touches, event) in
                    self?.touchesCancelled(touches, event)
                }
            } else {
                $0.touchesBegan = nil
                $0.touchesEnded = nil
                $0.touchesCancelled = nil
            }
        }
    }

    public func flashScrollIndicators() {
        overlayView.flashScrollIndicators()
    }

    public func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        tableView.setContentOffset(contentOffset, animated: animated)
    }

    public func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        tableView.scrollRectToVisible(rect, animated: animated)
    }

    public func scrollToItem(at indexPath: IndexPath, at scrollPosition: ScrollPosition, animated: Bool) {
        let contentOffset = contentOffsetForScrollingToItem(at: indexPath, at: scrollPosition)
        tableView.setContentOffset(contentOffset, animated: animated)
    }

    private func contentOffsetForScrollingToItem(at indexPath: IndexPath, at scrollPosition: ScrollPosition) -> CGPoint {
        let (column, row) = (indexPath.column, indexPath.row)
        guard column < numberOfColumns && row < numberOfRows else {
            fatalError("attempt to scroll to invalid index path: {column = \(column), row = \(row)}")
        }

        let columnRecords = columnHeaderView.columnRecords + tableView.columnRecords
        let rowRecords = rowHeaderView.rowRecords + tableView.rowRecords
        var contentOffset = CGPoint(x: columnRecords[column], y: rowRecords[row])

        let width: CGFloat
        let height: CGFloat
        if let mergedCell = mergedCell(for: Location(indexPath: indexPath)) {
            width = (mergedCell.from.column...mergedCell.to.column).reduce(0) { $0 + layoutProperties.columnWidthCache[$1] } + intercellSpacing.width
            height = (mergedCell.from.row...mergedCell.to.row).reduce(0) { $0 + layoutProperties.rowHeightCache[$1] } + intercellSpacing.height
        } else {
            width = layoutProperties.columnWidthCache[indexPath.column]
            height = layoutProperties.rowHeightCache[indexPath.row]
        }

        if circularScrollingOptions.direction.contains(.horizontally) {
            if contentOffset.x > centerOffset.x {
                contentOffset.x -= centerOffset.x
            } else {
                contentOffset.x += centerOffset.x
            }
        }

        var horizontalGroupCount = 0
        if scrollPosition.contains(.left) {
            horizontalGroupCount += 1
        }
        if scrollPosition.contains(.centeredHorizontally) {
            horizontalGroupCount += 1
            contentOffset.x = max(tableView.contentOffset.x + (contentOffset.x - (tableView.contentOffset.x + (tableView.frame.width - (width + intercellSpacing.width * 2)) / 2)), 0)
        }
        if scrollPosition.contains(.right) {
            horizontalGroupCount += 1
            contentOffset.x = max(contentOffset.x - tableView.frame.width + width + intercellSpacing.width * 2, 0)
        }

        if circularScrollingOptions.direction.contains(.vertically) {
            if contentOffset.y > centerOffset.y {
                contentOffset.y -= centerOffset.y
            } else {
                contentOffset.y += centerOffset.y
            }
        }

        var verticalGroupCount = 0
        if scrollPosition.contains(.top) {
            verticalGroupCount += 1
        }
        if scrollPosition.contains(.centeredVertically) {
            verticalGroupCount += 1
            contentOffset.y = max(tableView.contentOffset.y + contentOffset.y - (tableView.contentOffset.y + (tableView.frame.height - (height + intercellSpacing.height * 2)) / 2), 0)
        }
        if scrollPosition.contains(.bottom) {
            verticalGroupCount += 1
            contentOffset.y = max(contentOffset.y - tableView.frame.height + height + intercellSpacing.height * 2, 0)
        }

        let distanceFromRightEdge = tableView.contentSize.width - contentOffset.x
        if distanceFromRightEdge < tableView.frame.width {
            contentOffset.x -= tableView.frame.width - distanceFromRightEdge
        }
        let distanceFromBottomEdge = tableView.contentSize.height - contentOffset.y
        if distanceFromBottomEdge < tableView.frame.height {
            contentOffset.y -= tableView.frame.height - distanceFromBottomEdge
        }

        if horizontalGroupCount > 1 {
            fatalError("attempt to use a scroll position with multiple horizontal positioning styles")
        }
        if verticalGroupCount > 1 {
            fatalError("attempt to use a scroll position with multiple vertical positioning styles")
        }

        return contentOffset
    }

    public func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: ScrollPosition) {
        guard let indexPath = indexPath else {
            deselectAllItems(animated: animated)
            return
        }
        guard allowsSelection else {
            return
        }

        if !allowsMultipleSelection {
            selectedIndexPaths.remove(indexPath)
            deselectAllItems(animated: animated)
        }
        if selectedIndexPaths.insert(indexPath).inserted {
            if !scrollPosition.isEmpty {
                scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
                if animated {
                    pendingSelectionIndexPath = indexPath
                    return
                }
            }
            cellsForItem(at: indexPath).forEach {
                $0.setSelected(true, animated: animated)
            }
        }
    }

    public func deselectItem(at indexPath: IndexPath, animated: Bool) {
        cellsForItem(at: indexPath).forEach {
            $0.setSelected(false, animated: animated)
        }
        selectedIndexPaths.remove(indexPath)
    }

    private func deselectAllItems(animated: Bool) {
        selectedIndexPaths.forEach { deselectItem(at: $0, animated: animated) }
    }

    public func indexPathForItem(at point: CGPoint) -> IndexPath? {
        var row = 0
        var column = 0
        if tableView.convert(tableView.bounds, to: self).contains(point), let indexPath = indexPathForItem(at: point, in: tableView) {
            (row, column) = (indexPath.row + frozenRows, indexPath.column + frozenColumns)
        } else if rowHeaderView.convert(rowHeaderView.bounds, to: self).contains(point), let indexPath = indexPathForItem(at: point, in: rowHeaderView) {
            (row, column) = (indexPath.row, indexPath.column + frozenColumns)
        } else if columnHeaderView.convert(columnHeaderView.bounds, to: self).contains(point), let indexPath = indexPathForItem(at: point, in: columnHeaderView) {
            (row, column) = (indexPath.row + frozenRows, indexPath.column)
        } else if cornerView.convert(cornerView.bounds, to: self).contains(point), let indexPath = indexPathForItem(at: point, in: cornerView) {
            (row, column) = (indexPath.row, indexPath.column)
        } else {
            return nil
        }

        row = row % numberOfRows
        column = column % numberOfColumns

        let location = Location(row: row, column: column)
        if let mergedCell = mergedCell(for: location) {
            return IndexPath(row: mergedCell.from.row, column: mergedCell.from.column)
        }
        return IndexPath(row: location.row, column: location.column)
    }

    private func indexPathForItem(at location: CGPoint, in scrollView: ScrollView) -> IndexPath? {
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
        func isPointInRow(y: CGFloat, row: Int) -> Bool {
            guard row < scrollView.rowRecords.count else {
                return false
            }
            let minY = scrollView.rowRecords[row] + intercellSpacing.height
            let maxY = minY + layoutProperties.rowHeightCache[(row + scrollView.layoutAttributes.startRow) % numberOfRows]
            return y >= minY && y <= maxY
        }

        let point = convert(location, to: scrollView)
        let column = findIndex(in: scrollView.columnRecords, for: point.x - insetX)
        let row = findIndex(in: scrollView.rowRecords, for: point.y - insetY)

        switch (isPointInColumn(x: point.x - insetX, column: column), isPointInRow(y: point.y, row: row)) {
        case (true, true):
            return IndexPath(row: row, column: column)
        case (true, false):
            if isPointInRow(y: point.y - insetY, row: row + 1) {
                return IndexPath(row: row + 1, column: column)
            }
            return nil
        case (false, true):
            if isPointInColumn(x: point.x - insetX, column: column + 1) {
                return IndexPath(row: row, column: column + 1)
            }
            return nil
        case (false, false):
            if isPointInColumn(x: point.x - insetX, column: column + 1) && isPointInRow(y: point.y - insetY, row: row + 1) {
                return IndexPath(row: row + 1, column: column + 1)
            }
            return nil
        }
    }

    public func cellForItem(at indexPath: IndexPath) -> Cell? {
        if let cell = tableView.visibleCells.pairs
            .filter({ $0.key.row == indexPath.row && $0.key.column == indexPath.column })
            .map({ return $1 })
            .first {
            return cell
        }
        if let cell = rowHeaderView.visibleCells.pairs
            .filter({ $0.key.row == indexPath.row && $0.key.column == indexPath.column })
            .map({ return $1 })
            .first {
            return cell
        }
        if let cell = columnHeaderView.visibleCells.pairs
            .filter({ $0.key.row == indexPath.row && $0.key.column == indexPath.column })
            .map({ return $1 })
            .first {
            return cell
        }
        if let cell = cornerView.visibleCells.pairs
            .filter({ $0.key.row == indexPath.row && $0.key.column == indexPath.column })
            .map({ return $1 })
            .first {
            return cell
        }
        return nil
    }

    public func cellsForItem(at indexPath: IndexPath) -> [Cell] {
        var cells = [Cell]()
        cells.append(contentsOf:
            tableView.visibleCells.pairs
                .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column }
                .map { return $1 }
        )
        cells.append(contentsOf:
            rowHeaderView.visibleCells.pairs
                .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column }
                .map { return $1 }
        )
        cells.append(contentsOf:
            columnHeaderView.visibleCells.pairs
                .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column }
                .map { return $1 }
        )
        cells.append(contentsOf:
            cornerView.visibleCells.pairs
                .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column }
                .map { return $1 }
        )
        return cells
    }

    public func rectForItem(at indexPath: IndexPath) -> CGRect {
        let (column, row) = (indexPath.column, indexPath.row)
        guard column >= 0 && column < numberOfColumns && row >= 0 && row < numberOfRows else {
            return .zero
        }

        let columnRecords = columnHeaderView.columnRecords + tableView.columnRecords
        let rowRecords = rowHeaderView.rowRecords + tableView.rowRecords

        let x = columnRecords[column] + (column >= frozenColumns ? tableView.frame.origin.x : 0) + intercellSpacing.width
        let y = rowRecords[row] + (row >= frozenRows ? tableView.frame.origin.y : 0) + intercellSpacing.height
        let origin = CGPoint(x: x, y: y)

        let size: CGSize
        if let mergedCell = mergedCell(for: Location(row: row, column: column)) {
            let width = (mergedCell.from.column...mergedCell.to.column).reduce(0) { $0 + layoutProperties.columnWidthCache[$1] }
            let height = (mergedCell.from.row...mergedCell.to.row).reduce(0) { $0 + layoutProperties.rowHeightCache[$1] }
            size = CGSize(width: width, height: height)
        } else {
            size = CGSize(width: layoutProperties.columnWidthCache[column], height: layoutProperties.rowHeightCache[row])
        }

        return CGRect(origin: origin, size: size)
    }

    func mergedCell(for indexPath: Location) -> CellRange? {
        return layoutProperties.mergedCellLayouts[indexPath]
    }

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
        if needsReload && frozenColumns > 0 && frozenRows > 0 {
            columnHeaderView.frame.size.height -= cornerView.frame.height - intercellSpacing.height
            rowHeaderView.frame.size.width -= cornerView.frame.width - intercellSpacing.width
        }

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
            adjustOverlayViewFrame()
            arrangeScrollViews()
        }

        if circularScrollingOptions.direction.contains(.horizontally) {
            recenterHorizontallyIfNecessary()
        }
        if circularScrollingOptions.direction.contains(.vertically) {
            recenterVerticallyIfNecessary()
        }
    }

    public override func isKind(of aClass: AnyClass) -> Bool {
        return rootView.isKind(of: aClass)
    }
}

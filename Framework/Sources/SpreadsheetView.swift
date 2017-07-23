//
//  SpreadsheetView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

public class SpreadsheetView: UIView {
    /// The object that provides the data for the collection view.
    ///
    /// - Note: The data source must adopt the `SpreadsheetViewDataSource` protocol.
    ///   The spreadsheet view maintains a weak reference to the data source object.
    public weak var dataSource: SpreadsheetViewDataSource? {
        didSet {
            resetTouchHandlers(to: [tableView, columnHeaderView, rowHeaderView, cornerView])
            reloadData()
        }
    }
    /// The object that acts as the delegate of the spreadsheet view.
    /// - Note: The delegate must adopt the `SpreadsheetViewDelegate` protocol.
    ///   The spreadsheet view maintains a weak reference to the delegate object.
    ///
    ///   The delegate object is responsible for managing selection behavior and interactions with individual items.
    public weak var delegate: SpreadsheetViewDelegate?

    /// The horizontal and vertical spacing between cells.
    /// 
    /// - Note: The default spacing is `(1.0, 1.0)`. Negative values are not supported.
    public var intercellSpacing = CGSize(width: 1, height: 1)
    public var gridStyle: GridStyle = .solid(width: 1, color: .lightGray)

    /// A Boolean value that indicates whether users can select cells in the spreadsheet view.
    ///
    /// - Note: If the value of this property is `true` (the default), users can select cells.
    ///   If you want more fine-grained control over the selection of cells,
    ///   you must provide a delegate object and implement the appropriate methods of the `SpreadsheetViewDelegate` protocol.
    ///
    /// - SeeAlso: `allowsMultipleSelection`
    public var allowsSelection = true {
        didSet {
            if !allowsSelection {
                allowsMultipleSelection = false
            }
        }
    }
    /// A Boolean value that determines whether users can select more than one cell in the spreadsheet view.
    ///
    /// - Note: This property controls whether multiple cells can be selected simultaneously.
    ///   The default value of this property is `false`.
    ///
    ///   When the value of this property is true, tapping a cell adds it to the current selection (assuming the delegate permits the cell to be selected).
    ///   Tapping the cell again removes it from the selection.
    ///
    /// - SeeAlso: `allowsSelection`
    public var allowsMultipleSelection = false {
        didSet {
            if allowsMultipleSelection {
                allowsSelection = true
            }
        }
    }

    /// A Boolean value that controls whether the vertical scroll indicator is visible.
    ///
    /// The default value is `true`. The indicator is visible while tracking is underway and fades out after tracking.
    public var showsVerticalScrollIndicator = true {
        didSet {
            overlayView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
    }
    /// A Boolean value that controls whether the horizontal scroll indicator is visible.
    ///
    /// The default value is `true`. The indicator is visible while tracking is underway and fades out after tracking.
    public var showsHorizontalScrollIndicator = true {
        didSet {
            overlayView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
    }

    /// A Boolean value that controls whether the scroll-to-top gesture is enabled.
    ///
    /// - Note: The scroll-to-top gesture is a tap on the status bar. When a user makes this gesture,
    /// the system asks the scroll view closest to the status bar to scroll to the top.
    /// If that scroll view has `scrollsToTop` set to `false`, its delegate returns false from `scrollViewShouldScrollToTop(_:)`, 
    /// or the content is already at the top, nothing happens.
    ///
    /// After the scroll view scrolls to the top of the content view, it sends the delegate a `scrollViewDidScrollToTop(_:)` message.
    ///
    /// The default value of scrollsToTop is `true`.
    ///
    /// On iPhone, the scroll-to-top gesture has no effect if there is more than one scroll view on-screen that has `scrollsToTop` set to `true`.
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

    /// The view that provides the background appearance.
    ///
    /// - Note: The view (if any) in this property is positioned underneath all of the other content and sized automatically to fill the entire bounds of the spreadsheet view.
    /// The background view does not scroll with the spreadsheet view’s other content. The spreadsheet view maintains a strong reference to the background view object.
    ///
    /// This property is nil by default, which displays the background color of the spreadsheet view.
    public var backgroundView: UIView? {
        willSet {
            backgroundView?.removeFromSuperview()
        }
        didSet {
            if let backgroundView = backgroundView {
                backgroundView.frame = bounds
                backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                super.insertSubview(backgroundView, at: 0)
            }
        }
    }

    /// Returns an array of visible cells currently displayed by the spreadsheet view.
    ///
    /// - Note: This method returns the complete list of visible cells displayed by the collection view.
    ///
    /// - Returns: An array of `Cell` objects. If no cells are visible, this method returns an empty array.
    public var visibleCells: [Cell] {
        let cells: [Cell] = Array(columnHeaderView.visibleCells) + Array(rowHeaderView.visibleCells)
            + Array(cornerView.visibleCells) + Array(tableView.visibleCells)
        return cells.sorted()
    }


    /// An array of the visible items in the collection view.
    /// - Note: The value of this property is a sorted array of IndexPath objects, each of which corresponds to a visible cell in the spreadsheet view.
    /// If there are no visible items, the value of this property is an empty array.
    ///
    /// - SeeAlso: `visibleCells`
    public var indexPathsForVisibleItems: [IndexPath] {
        return visibleCells.map { $0.indexPath }
    }

    public var indexPathForSelectedItem: IndexPath? {
        return Array(selectedIndexPaths).sorted().first
    }

    /// The index paths for the selected items.
    /// - Note: The value of this property is an array of IndexPath objects, each of which corresponds to a single selected item.
    /// If there are no selected items, the value of this property is nil.
    public var indexPathsForSelectedItems: [IndexPath] {
        return Array(selectedIndexPaths).sorted()
    }

    /// A Boolean value that determines whether scrolling is disabled in a particular direction.
    /// - Note: If this property is `false`, scrolling is permitted in both horizontal and vertical directions.
    /// If this property is `true` and the user begins dragging in one general direction (horizontally or vertically), the scroll view disables scrolling in the other direction.
    /// If the drag direction is diagonal, then scrolling will not be locked and the user can drag in any direction until the drag completes.
    /// The default value is `false`
    public var isDirectionalLockEnabled = false {
        didSet {
            tableView.isDirectionalLockEnabled = isDirectionalLockEnabled
        }
    }

    /// A Boolean value that controls whether the scroll view bounces past the edge of content and back again.
    /// - Note: If the value of this property is `true`, the scroll view bounces when it encounters a boundary of the content.
    /// Bouncing visually indicates that scrolling has reached an edge of the content.
    /// If the value is `false`, scrolling stops immediately at the content boundary without bouncing.
    /// The default value is `true`.
    ///
    /// - SeeAlso: `alwaysBounceHorizontal`, `alwaysBounceVertical`
    public var bounces: Bool {
        get {
            return tableView.bounces
        }
        set {
            tableView.bounces = newValue
        }
    }

    /// A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content.
    /// - Note: If this property is set to true and `bounces` is `true`, vertical dragging is allowed even if the content is smaller than the bounds of the scroll view.
    /// The default value is `false`.
    ///
    /// - SeeAlso: `alwaysBounceHorizontal`
    public var alwaysBounceVertical: Bool {
        get {
            return tableView.alwaysBounceVertical
        }
        set {
            tableView.alwaysBounceVertical = newValue
        }
    }

    /// A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view.
    /// - Note: If this property is set to `true` and `bounces` is `true`, horizontal dragging is allowed even if the content is smaller than the bounds of the scroll view.
    /// The default value is `false`.
    ///
    /// - SeeAlso: `alwaysBounceVertical`
    public var alwaysBounceHorizontal: Bool {
        get {
            return tableView.alwaysBounceHorizontal
        }
        set {
            tableView.alwaysBounceHorizontal = newValue
        }
    }
    
    /// A Boolean value that determines wheather the row header always sticks to the top.
    /// - Note: `bounces` has to be `true` and there has to be at least one `frozenRow`.
    /// The default value is `false`.
    ///
    /// - SeeAlso: `stickyColumnHeader`
    public var stickyRowHeader: Bool = false
    
    /// A Boolean value that determines wheather the column header always sticks to the top.
    /// - Note: `bounces` has to be `true` and there has to be at least one `frozenColumn`.
    /// The default value is `false`.
    ///
    /// - SeeAlso: `stickyRowHeader`
    public var stickyColumnHeader: Bool = false

    /// A Boolean value that determines whether paging is enabled for the scroll view.
    /// - Note: If the value of this property is `true`, the scroll view stops on multiples of the scroll view’s bounds when the user scrolls.
    /// The default value is false.
    public var isPagingEnabled: Bool {
        get {
            return tableView.isPagingEnabled
        }
        set {
            tableView.isPagingEnabled = newValue
        }
    }

    /// A Boolean value that determines whether scrolling is enabled.
    /// - Note: If the value of this property is `true`, scrolling is enabled, and if it is `false`, scrolling is disabled. The default is `true`.
    ///
    /// When scrolling is disabled, the scroll view does not accept touch events; it forwards them up the responder chain.
    public var isScrollEnabled: Bool {
        get {
            return tableView.isScrollEnabled
        }
        set {
            tableView.isScrollEnabled = newValue
            overlayView.isScrollEnabled = newValue
        }
    }

    /// The style of the scroll indicators.
    /// - Note: The default style is `default`. See `UIScrollViewIndicatorStyle` for descriptions of these constants.
    public var indicatorStyle: UIScrollViewIndicatorStyle {
        get {
            return overlayView.indicatorStyle
        }
        set {
            overlayView.indicatorStyle = newValue
        }
    }

    /// A floating-point value that determines the rate of deceleration after the user lifts their finger.
    /// - Note: Your application can use the `UIScrollViewDecelerationRateNormal` and UIScrollViewDecelerationRateFast` constants as reference points for reasonable deceleration rates.
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
        rootView.delegate = self
        super.addSubview(rootView)

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
        super.addSubview(overlayView)

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
        circularScrollScalingFactor = determineCircularScrollScalingFactor()
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

        cornerView.frame = .zero
        columnHeaderView.frame = CGRect(x: 0, y: 0, width: 0, height: rootView.frame.height)
        rowHeaderView.frame = CGRect(x: 0, y: 0, width: rootView.frame.width, height: 0)
        tableView.frame = CGRect(origin: .zero, size: rootView.frame.size)

        cornerView.frame.size = cornerView.contentSize
        columnHeaderView.frame.size.width = columnHeaderView.contentSize.width
        rowHeaderView.frame.size.height = rowHeaderView.contentSize.height
        if frozenColumns > 0 && frozenRows > 0 {
            columnHeaderView.frame.size.height -= cornerView.frame.height - intercellSpacing.height
            rowHeaderView.frame.size.width -= cornerView.frame.width - intercellSpacing.width
        }
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

        if contentOffset.x < 0 {
            contentOffset.x = 0
        }
        if contentOffset.y < 0 {
            contentOffset.y = 0
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

        let origin: CGPoint
        let size: CGSize
        func originFor(column: Int, row: Int) -> CGPoint {
            let x = columnRecords[column] + (column >= frozenColumns ? tableView.frame.origin.x : 0) + intercellSpacing.width
            let y = rowRecords[row] + (row >= frozenRows ? tableView.frame.origin.y : 0) + intercellSpacing.height
            return CGPoint(x: x, y: y)
        }
        if let mergedCell = mergedCell(for: Location(row: row, column: column)) {
            origin = originFor(column: mergedCell.from.column, row: mergedCell.from.row)

            var width: CGFloat = 0
            var height: CGFloat = 0
            for column in mergedCell.from.column...mergedCell.to.column {
                width += layoutProperties.columnWidthCache[column]
            }
            for row in mergedCell.from.row...mergedCell.to.row {
                height += layoutProperties.rowHeightCache[row]
            }
            size = CGSize(width: width + intercellSpacing.width * CGFloat(mergedCell.columnCount - 1),
                          height: height + intercellSpacing.height * CGFloat(mergedCell.rowCount - 1))
        } else {
            origin = originFor(column: column, row: row)

            let width = layoutProperties.columnWidthCache[column]
            let height = layoutProperties.rowHeightCache[row]
            size = CGSize(width: width, height: height)
        }
        return CGRect(origin: origin, size: size)
    }

    func mergedCell(for indexPath: Location) -> CellRange? {
        return layoutProperties.mergedCellLayouts[indexPath]
    }
}

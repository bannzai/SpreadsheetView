//
//  SpreadsheetView.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 3/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

public protocol SpreadsheetViewScrollDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView)
}

open class SpreadsheetView: UIView {
  /// The object that provides the data for the collection view.
  ///
  /// - Note: The data source must adopt the `SpreadsheetViewDataSource` protocol.
  ///   The spreadsheet view maintains a weak reference to the data source object.
  public weak var dataSource: SpreadsheetViewDataSource? {
    didSet {
      resetTouchHandlers(to: [tableView, columnHeaderView, columnHeaderViewRight, rowHeaderView, cornerView, cornerViewRight])
      setNeedsReload()
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
        guard #available(iOS 11.0, *) else {
          super.insertSubview(backgroundView, at: 0)
          return
        }
      }
    }
  }
  
  #if swift(>=3.2)
  @available(iOS 11.0, *)
  open override func safeAreaInsetsDidChange() {
    if let backgroundView = backgroundView {
      backgroundView.removeFromSuperview()
      super.insertSubview(backgroundView, at: 0)
    }
  }
  #endif
  
  /// Returns an array of visible cells currently displayed by the spreadsheet view.
  ///
  /// - Note: This method returns the complete list of visible cells displayed by the collection view.
  ///
  /// - Returns: An array of `Cell` objects. If no cells are visible, this method returns an empty array.
  public var visibleCells: [Cell] {
    let cells: [Cell] = Array(columnHeaderView.visibleCells) + Array(columnHeaderViewRight.visibleCells) + Array(rowHeaderView.visibleCells)
    let cells_: [Cell] = cells + Array(cornerView.visibleCells) + Array(cornerViewRight.visibleCells) + Array(tableView.visibleCells)
    return cells_.sorted()
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
  public var indicatorStyle: UIScrollView.IndicatorStyle {
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
      return tableView.decelerationRate.rawValue
    }
    set {
      tableView.decelerationRate = UIScrollView.DecelerationRate(rawValue: newValue)
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
  public var frozenColumnsRight: Int {
    return layoutProperties.frozenColumnsRight
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
  
  var columnHeaderView = ScrollView()
  var columnHeaderViewRight = ScrollView()
  
  var rowHeaderView = ScrollView()
  
  var cornerView = ScrollView()
  var cornerViewRight = ScrollView()
  
  var tableView = ScrollView()
  
  private var cellClasses = [String: Cell.Type]()
  private var cellNibs = [String: UINib]()
  var cellReuseQueues = [String: ReuseQueue<Cell>]()
  let blankCellReuseIdentifier = UUID().uuidString
  
  var horizontalGridlineReuseQueue = ReuseQueue<Gridline>()
  var verticalGridlineReuseQueue = ReuseQueue<Gridline>()
  var borderReuseQueue = ReuseQueue<Border>()
  
  var highlightedIndexPaths = Set<IndexPath>()
  var selectedIndexPaths = Set<IndexPath>()
  var pendingSelectionIndexPath: IndexPath?
  var currentTouch: UITouch?
  
  private var needsReload = true
  
  open var dividerColor: UIColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
  open var dividerThickness: CGFloat = 0.5
  
  open var scrollDelegate: SpreadsheetViewScrollDelegate? = nil
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  open func setup() {
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
    
    columnHeaderViewRight.frame = bounds
    columnHeaderViewRight.frame.size.width = 0
    columnHeaderViewRight.autoresizingMask = [.flexibleHeight]
    columnHeaderViewRight.autoresizesSubviews = false
    columnHeaderViewRight.showsHorizontalScrollIndicator = false
    columnHeaderViewRight.showsVerticalScrollIndicator = false
    columnHeaderViewRight.isHidden = true
    columnHeaderViewRight.delegate = self
    
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
    
    cornerViewRight.autoresizesSubviews = false
    cornerViewRight.isHidden = true
    cornerViewRight.delegate = self
    
    overlayView.frame = bounds
    overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    overlayView.autoresizesSubviews = false
    overlayView.isUserInteractionEnabled = false
    
    rootView.addSubview(tableView)
    
    rootView.addSubview(columnHeaderView)
    rootView.addSubview(columnHeaderViewRight)
    
    rootView.addSubview(rowHeaderView)
    
    rootView.addSubview(cornerView)
    rootView.addSubview(cornerViewRight)
    
    super.addSubview(overlayView)
    
    [tableView, columnHeaderView, columnHeaderViewRight, rowHeaderView, cornerView, cornerViewRight, overlayView].forEach {
      addGestureRecognizer($0.panGestureRecognizer)
      #if swift(>=3.2)
      if #available(iOS 11.0, *) {
        $0.contentInsetAdjustmentBehavior = .never
      }
      #endif
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
  
  public var scrollView: UIScrollView {
    return overlayView
  }
  
  public var spreadSheetTableView: UIScrollView {
    return self.tableView
  }
  
  public var spreadSheetRootView: UIScrollView {
    return self.rootView
  }
  
  public var spreadSheetColumnViews: [UIScrollView] {
    return [self.columnHeaderView, self.columnHeaderViewRight]
  }
  
  public var spreadSheetRowViews: [UIScrollView] {
    return [self.rowHeaderView]
  }
  
  public var spreadSheetCornerViews: [UIScrollView] {
    return [self.cornerView, self.cornerViewRight]
  }
  
  public func reloadData() {
    layoutProperties = resetLayoutProperties()
    circularScrollScalingFactor = determineCircularScrollScalingFactor()
    centerOffset = calculateCenterOffset()
    
    cornerView.layoutAttributes = layoutAttributeForCornerView()
    cornerViewRight.layoutAttributes = layoutAttributeForCornerViewRight()
    
    columnHeaderView.layoutAttributes = layoutAttributeForColumnHeaderView()
    columnHeaderViewRight.layoutAttributes = layoutAttributeForColumnHeaderViewRight()
    
    rowHeaderView.layoutAttributes = layoutAttributeForRowHeaderView()
    tableView.layoutAttributes = layoutAttributeForTableView()
    
    cornerView.resetReusableObjects()
    cornerViewRight.resetReusableObjects()
    
    columnHeaderView.resetReusableObjects()
    columnHeaderViewRight.resetReusableObjects()
    
    rowHeaderView.resetReusableObjects()
    tableView.resetReusableObjects()
    
    resetContentSize(of: cornerView)
    resetContentSize(of: cornerViewRight)
    resetContentSize(of: columnHeaderView)
    resetContentSize(of: columnHeaderViewRight)
    resetContentSize(of: rowHeaderView)
    resetContentSize(of: tableView)
    
    resetScrollViewFrame()
    resetScrollViewArrangement()
    
    if circularScrollingOptions.direction.contains(.horizontally) && tableView.contentOffset.x == 0 {
      scrollToHorizontalCenter()
    }
    if circularScrollingOptions.direction.contains(.vertically) && tableView.contentOffset.y == 0 {
      scrollToVerticalCenter()
    }
    
    needsReload = false
    setNeedsLayout()
  }
  
  func reloadDataIfNeeded() {
    if needsReload {
      reloadData()
    }
  }
  
  private func setNeedsReload() {
    needsReload = true
    setNeedsLayout()
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
  
  public func scrollToItem(at indexPath: IndexPath, at scrollPosition: ScrollPosition, animated: Bool) {
    let contentOffset = contentOffsetForScrollingToItem(at: indexPath, at: scrollPosition)
    tableView.setContentOffset(contentOffset, animated: animated)
  }
  
  private func contentOffsetForScrollingToItem(at indexPath: IndexPath, at scrollPosition: ScrollPosition) -> CGPoint {
    let (column, row) = (indexPath.column, indexPath.row)
    guard column < numberOfColumns && row < numberOfRows else {
      fatalError("attempt to scroll to invalid index path: {column = \(column), row = \(row)}")
    }
    
    let columnRecords = columnHeaderView.columnRecords + tableView.columnRecords + columnHeaderViewRight.columnRecords
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
    }  else if columnHeaderViewRight.convert(columnHeaderViewRight.bounds, to: self).contains(point), let indexPath = indexPathForItem(at: point, in: columnHeaderViewRight) {
      (row, column) = (indexPath.row + frozenRows, indexPath.column)
    } else if cornerView.convert(cornerView.bounds, to: self).contains(point), let indexPath = indexPathForItem(at: point, in: cornerView) {
      (row, column) = (indexPath.row, indexPath.column)
    } else if cornerViewRight.convert(cornerViewRight.bounds, to: self).contains(point), let indexPath = indexPathForItem(at: point, in: cornerViewRight) {
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
    if let cell = columnHeaderViewRight.visibleCells.pairs
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
    if let cell = cornerViewRight.visibleCells.pairs
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
      columnHeaderViewRight.visibleCells.pairs
        .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column }
        .map { return $1 }
    )
    cells.append(contentsOf:
      cornerView.visibleCells.pairs
        .filter { $0.key.row == indexPath.row && $0.key.column == indexPath.column }
        .map { return $1 }
    )
    cells.append(contentsOf:
      cornerViewRight.visibleCells.pairs
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
    
    let columnRecords = columnHeaderView.columnRecords + tableView.columnRecords + columnHeaderViewRight.columnRecords
    let rowRecords = rowHeaderView.rowRecords + tableView.rowRecords
    
    let origin: CGPoint
    let size: CGSize
    func originFor(column: Int, row: Int) -> CGPoint {
      var x = CGFloat(columnRecords[column]) + intercellSpacing.width
      if column >= layoutProperties.numberOfColumns - frozenColumns {
        x = columnRecords[column] + (self.frame.size.width - layoutProperties.columnWidthCache.suffix(from: column).reduce(0) { $0 + $1 }) + intercellSpacing.width
      } else if column >= frozenColumns && column < layoutProperties.numberOfColumns - frozenColumns {
        x = columnRecords[column] + tableView.frame.origin.x + intercellSpacing.width
      }
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
  
  open func resetLayoutProperties() -> LayoutProperties {
    guard let dataSource = dataSource else {
      return LayoutProperties()
    }
    
    let numberOfColumns = dataSource.numberOfColumns(in: self)
    let numberOfRows = dataSource.numberOfRows(in: self)
    
    let frozenColumns = dataSource.frozenColumns(in: self)
    let frozenColumnsRight = dataSource.frozenColumnsRight(in: self)
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
                            frozenColumns: frozenColumns, frozenColumnsRight: frozenColumnsRight, frozenRows: frozenRows,
                            frozenColumnWidth: frozenColumnWidth, frozenRowHeight: frozenRowHeight,
                            columnWidth: columnWidth, rowHeight: rowHeight,
                            columnWidthCache: columnWidthCache, rowHeightCache: rowHeightCache,
                            mergedCells: mergedCells, mergedCellLayouts: mergedCellLayouts)
  }
  
  open func layoutAttributeForCornerView() -> LayoutAttributes {
    return LayoutAttributes(startColumn: 0,
                            startRow: 0,
                            numberOfColumns: frozenColumns,
                            numberOfRows: frozenRows,
                            columnCount: frozenColumns,
                            rowCount: frozenRows,
                            insets: .zero)
  }
  
  open func layoutAttributeForCornerViewRight() -> LayoutAttributes {
    return LayoutAttributes(startColumn: layoutProperties.numberOfColumns - frozenColumnsRight,
                            startRow: 0,
                            numberOfColumns: frozenColumnsRight,
                            numberOfRows: frozenRows,
                            columnCount: layoutProperties.numberOfColumns,
                            rowCount: frozenRows,
                            insets: .zero)
  }
  
  open func layoutAttributeForColumnHeaderView() -> LayoutAttributes {
    let insets = circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow ? CGPoint(x: 0, y: layoutProperties.rowHeightCache.prefix(upTo: frozenRows).reduce(0) { $0 + $1 } + intercellSpacing.height * CGFloat(layoutProperties.frozenRows)) : .zero
    return LayoutAttributes(startColumn: 0,
                            startRow: layoutProperties.frozenRows,
                            numberOfColumns: layoutProperties.frozenColumns,
                            numberOfRows: layoutProperties.numberOfRows,
                            columnCount: layoutProperties.frozenColumns,
                            rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
                            insets: insets)
  }
  
  open func layoutAttributeForColumnHeaderViewRight() -> LayoutAttributes {
    let insets = circularScrollingOptions.headerStyle == .columnHeaderStartsFirstRow ? CGPoint(x: 0, y: layoutProperties.rowHeightCache.prefix(upTo: frozenRows).reduce(0) { $0 + $1 } + intercellSpacing.height * CGFloat(layoutProperties.frozenRows)) : .zero
    return LayoutAttributes(startColumn: layoutProperties.numberOfColumns - frozenColumnsRight,
                            startRow: layoutProperties.frozenRows,
                            numberOfColumns: layoutProperties.frozenColumnsRight,
                            numberOfRows: layoutProperties.numberOfRows,
                            columnCount: layoutProperties.numberOfColumns,
                            rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
                            insets: insets)
  }
  
  open func layoutAttributeForRowHeaderView() -> LayoutAttributes {
    let insets = circularScrollingOptions.headerStyle == .rowHeaderStartsFirstColumn ? CGPoint(x: layoutProperties.columnWidthCache.prefix(upTo: frozenColumns).reduce(0) { $0 + $1 } + intercellSpacing.width * CGFloat(layoutProperties.frozenColumns), y: 0) : .zero
    return LayoutAttributes(startColumn: layoutProperties.frozenColumns,
                            startRow: 0,
                            numberOfColumns: layoutProperties.numberOfColumns,
                            numberOfRows: layoutProperties.frozenRows,
                            columnCount: layoutProperties.numberOfColumns * circularScrollScalingFactor.horizontal,
                            rowCount: layoutProperties.frozenRows,
                            insets: insets)
  }
  
  open func layoutAttributeForTableView() -> LayoutAttributes {
    return LayoutAttributes(startColumn: layoutProperties.frozenColumns,
                            startRow: layoutProperties.frozenRows,
                            numberOfColumns: layoutProperties.numberOfColumns,
                            numberOfRows: layoutProperties.numberOfRows,
                            columnCount: layoutProperties.numberOfColumns * circularScrollScalingFactor.horizontal,
                            rowCount: layoutProperties.numberOfRows * circularScrollScalingFactor.vertical,
                            insets: .zero)
  }
  
  open func layout(scrollView: ScrollView) {
    let layoutEngine = LayoutEngine(spreadsheetView: self, scrollView: scrollView)
    layoutEngine.layout()
  }
  
  open func resetContentSize(of scrollView: ScrollView) {
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
  
  open func touchesBegan(_ touches: Set<UITouch>, _ event: UIEvent?) {
    guard currentTouch == nil else {
      return
    }
    currentTouch = touches.first
    
    NSObject.cancelPreviousPerformRequests(withTarget: self)
    unhighlightAllItems()
    highlightItems(on: touches)
    if !allowsMultipleSelection,
      let touch = touches.first, let indexPath = indexPathForItem(at: touch.location(in: self)),
      let cell = cellForItem(at: indexPath), cell.isUserInteractionEnabled {
      selectedIndexPaths.forEach {
        cellsForItem(at: $0).forEach { $0.isSelected = false }
      }
    }
  }
  
  open func touchesEnded(_ touches: Set<UITouch>, _ event: UIEvent?) {
    guard let touch = touches.first, touch == currentTouch else {
      return
    }
    
    let highlightedItems = highlightedIndexPaths
    unhighlightAllItems()
    if allowsMultipleSelection,
      let touch = touches.first, let indexPath = indexPathForItem(at: touch.location(in: self)),
      selectedIndexPaths.contains(indexPath) {
      if delegate?.spreadsheetView(self, shouldDeselectItemAt: indexPath) ?? true {
        deselectItem(at: indexPath)
      }
    } else {
      selectItems(on: touches, highlightedItems: highlightedItems)
    }
    
    perform(#selector(clearCurrentTouch), with: nil, afterDelay: 0)
  }
  
  private func selectItem(at indexPath: IndexPath) {
    let cells = cellsForItem(at: indexPath)
    if !cells.isEmpty && delegate?.spreadsheetView(self, shouldSelectItemAt: indexPath) ?? true {
      if !allowsMultipleSelection {
        selectedIndexPaths.remove(indexPath)
        deselectAllItems()
      }
      cells.forEach {
        $0.isSelected = true
      }
      delegate?.spreadsheetView(self, didSelectItemAt: indexPath)
      selectedIndexPaths.insert(indexPath)
    }
  }
  
  private func deselectItem(at indexPath: IndexPath) {
    let cells = cellsForItem(at: indexPath)
    cells.forEach {
      $0.isSelected = false
    }
    delegate?.spreadsheetView(self, didDeselectItemAt: indexPath)
    selectedIndexPaths.remove(indexPath)
  }
  
  private func selectItems(on touches: Set<UITouch>, highlightedItems: Set<IndexPath>) {
    guard allowsSelection else {
      return
    }
    if let touch = touches.first {
      if let indexPath = indexPathForItem(at: touch.location(in: self)), highlightedItems.contains(indexPath) {
        selectItem(at: indexPath)
      }
    }
  }
  
  private func deselectAllItems() {
    selectedIndexPaths.forEach { deselectItem(at: $0) }
  }
  
  open func touchesCancelled(_ touches: Set<UITouch>, _ event: UIEvent?) {
    unhighlightAllItems()
    perform(#selector(restorePreviousSelection), with: touches, afterDelay: 0)
    perform(#selector(clearCurrentTouch), with: nil, afterDelay: 0)
  }
  
  private func highlightItems(on touches: Set<UITouch>) {
    guard allowsSelection else {
      return
    }
    if let touch = touches.first {
      if let indexPath = indexPathForItem(at: touch.location(in: self)) {
        guard let cell = cellForItem(at: indexPath), cell.isUserInteractionEnabled else {
          return
        }
        if delegate?.spreadsheetView(self, shouldHighlightItemAt: indexPath) ?? true {
          highlightedIndexPaths.insert(indexPath)
          cellsForItem(at: indexPath).forEach {
            $0.isHighlighted = true
          }
          delegate?.spreadsheetView(self, didHighlightItemAt: indexPath)
        }
      }
    }
  }
  
  private func unhighlightAllItems() {
    highlightedIndexPaths.forEach { (indexPath) in
      cellsForItem(at: indexPath).forEach {
        $0.isHighlighted = false
      }
      delegate?.spreadsheetView(self, didUnhighlightItemAt: indexPath)
    }
    highlightedIndexPaths.removeAll()
  }
  
}

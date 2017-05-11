import Foundation
import SpreadsheetView

public class SpreadsheetViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    public var spreadsheetView = SpreadsheetView()

    public var numberOfColumns: (_ spreadsheetView: SpreadsheetView) -> Int = { _ in return 0 }
    public var numberOfRows: (_ spreadsheetView: SpreadsheetView) -> Int = { _ in return 0 }

    public var widthForColumn: (_ spreadsheetView: SpreadsheetView, _ column: Int) -> CGFloat = { _ in return 0 }
    public var heightForRow: (_ spreadsheetView: SpreadsheetView, _ column: Int) -> CGFloat = { _ in return 0 }

    public var cellForItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Cell? = { _ in return nil }

    public var mergedCells: (_ spreadsheetView: SpreadsheetView) -> [CellRange] = { _ in return [] }

    public var frozenColumns: (_ spreadsheetView: SpreadsheetView) -> Int = { _ in return 0 }
    public var frozenRows: (_ spreadsheetView: SpreadsheetView) -> Int = { _ in return 0 }

    public var shouldHighlightItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Bool = { _ in return true }
    public var didHighlightItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Void = { _ in }
    public var didUnhighlightItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Void = { _ in }
    public var shouldSelectItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Bool = { _ in return true }
    public var shouldDeselectItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Bool = { _ in return true }
    public var didSelectItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Void = { _ in }
    public var didDeselectItemAt: (_ spreadsheetView: SpreadsheetView, _ indexPath: IndexPath) -> Void = { _ in }

    public override func viewDidLoad() {
        super.viewDidLoad()

        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self

        spreadsheetView.frame = view.bounds
        spreadsheetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        spreadsheetView.backgroundView = backgroundView

        view.addSubview(spreadsheetView)
    }

    // DataSource

    public func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return numberOfColumns(spreadsheetView)
    }

    public func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return numberOfRows(spreadsheetView)
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return widthForColumn(spreadsheetView, column)
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return heightForRow(spreadsheetView, row)
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        return cellForItemAt(spreadsheetView, indexPath)
    }

    public func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        return mergedCells(spreadsheetView)
    }

    public func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return frozenColumns(spreadsheetView)
    }

    public func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return frozenRows(spreadsheetView)
    }

    // Delegate

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return shouldHighlightItemAt(spreadsheetView, indexPath)
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, didHighlightItemAt indexPath: IndexPath) {
        didHighlightItemAt(spreadsheetView, indexPath)
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, didUnhighlightItemAt indexPath: IndexPath) {
        didUnhighlightItemAt(spreadsheetView, indexPath)
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return shouldSelectItemAt(spreadsheetView, indexPath)
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return shouldDeselectItemAt(spreadsheetView, indexPath)
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemAt(spreadsheetView, indexPath)
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, didDeselectItemAt indexPath: IndexPath) {
        didDeselectItemAt(spreadsheetView, indexPath)
    }
}

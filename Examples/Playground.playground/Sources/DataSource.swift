import Foundation
import SpreadsheetView

public class DataSource: SpreadsheetViewDataSource {
    public init() {}

    public func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 40
    }

    public func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 60
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 80
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 50
    }

    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DebugCell
        cell.indexPath = indexPath
        return cell
    }
}

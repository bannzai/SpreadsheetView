import UIKit
import PlaygroundSupport
import SpreadsheetView

let viewController = SpreadsheetViewController()

viewController.numberOfColumns = { _ in return 60 }
viewController.numberOfRows = { _ in return 80 }
viewController.widthForColumn = { _ in return 60 }
viewController.heightForRow = { _ in return 40 }
viewController.frozenColumns = { _ in return 1 }
viewController.frozenRows = { _ in return 2 }
viewController.cellForItemAt = {
    let cell = $0.dequeueReusableCell(withReuseIdentifier: "cell", for: $1) as! DebugCell
    cell.indexPath = $1
    return cell
}

viewController.spreadsheetView.register(DebugCell.self, forCellWithReuseIdentifier: "cell")

PlaygroundPage.current.liveView = viewController

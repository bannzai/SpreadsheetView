import UIKit
import PlaygroundSupport
import SpreadsheetView

let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
containerView.backgroundColor = .white

let spreadsheetView = SpreadsheetView()

spreadsheetView.frame = containerView.bounds
containerView.addSubview(spreadsheetView)

PlaygroundPage.current.liveView = containerView

let bgView = UIView()
bgView.frame = spreadsheetView.bounds
bgView.backgroundColor = .lightGray
spreadsheetView.backgroundView = bgView

spreadsheetView.register(DebugCell.self, forCellWithReuseIdentifier: "cell")

let dataSource = DataSource()
spreadsheetView.dataSource = dataSource

//
//  ViewController.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/8/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class ViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    let weeks = ["Week #14", "Week #15", "Week #16", "Week #17", "Week #18", "Week #19", "Week #20"]
    // Task, Start, Duration, Color
    let tasks = [
        ["Office itinerancy", "2", "17", "0"],
        ["Office facing", "2", "8", "0"],
        ["Interior office", "2", "7", "1"],
        ["Air condition check", "3", "7", "1"],
        ["Furniture installation", "11", "8", "1"],
        ["Workplaces preparation", "11", "8", "2"],
        ["The emproyee relocation", "14", "5", "2"],
        ["Preparing workspace", "14", "5", "1"],
        ["Workspaces importation", "14", "4", "1"],
        ["Workspaces exportation", "14", "3", "0"],
        ["Product launch", "2", "13", "0"],
        ["Perforn Initial testing", "3", "5", "0"],
        ["Development", "3", "11", "1"],
        ["Develop System", "3", "2", "1"],
        ["Beta Realese", "6", "2", "1"],
        ["Integrate System", "8", "2", "1"],
        ["Test", "10", "4", "2"],
        ["Promotion", "22", "8", "2"],
        ["Service", "18", "12", "2"],
        ["Marketing", "10", "4", "1"],
        ["The emproyee relocation", "14", "5", "1"],
        ["Land Survey", "4", "8", "1"],
        ["Plan Design", "6", "2", "1"],
        ["Test", "10", "4", "0"],
        ["Determine Cost", "18", "4", "0"],
        ["Review Hardware", "20", "6", "0"],
        ["Engineering", "6", "8", "1"],
        ["Define Concept", "9", "10", "1"],
        ["Compile Report", "14", "10", "1"],
        ["Air condition check", "3", "7", "1"],
        ["Review Data", "16", "20", "2"],
        ["Integrate System", "8", "2", "2"],
        ["Test", "10", "4", "2"],
        ["Determine Cost", "18", "4", "0"],
        ["Review Hardware", "20", "6", "0"],
        ["User Interview", "14", "5", "1"],
        ["Network", "16", "6", "1"],
        ["Software", "8", "8", "1"],
        ["Preparing workspace", "14", "5", "0"],
        ["Workspaces importation", "14", "4", "0"],
        ["Procedure", "10", "4", "0"],
        ["Perforn Initial testing", "3", "5", "0"],
        ["Development", "3", "11", "2"],
        ["Develop System", "3", "2", "2"],
        ["Interior office", "2", "7", "2"],
        ["Air condition check", "3", "7", "1"],
        ["Furniture installation", "11", "8", "1"],
        ["Beta Realese", "6", "2", "0"],
        ["Marketing", "10", "4", "0"],
        ["The emproyee relocation", "14", "5", "0"],
        ["Land Survey", "4", "8", "0"],
        ["Forms", "12", "3", "1"],
        ["Workspaces importation", "14", "4", "1"],
        ["Procedure", "10", "4", "2"],
        ["Perforn Initial testing", "3", "5", "2"],
        ["Development", "3", "11", "2"],
        ["Website", "14", "6", "2"],
        ["Assemble", "3", "4", "0"],
        ["Air condition check", "3", "7", "0"],
        ["Furniture installation", "11", "8", "0"],
        ["Workplaces preparation", "11", "8", "1"],
        ["Sales", "5", "6", "1"],
        ["Unit Test", "7", "8", "2"],
        ["Integration Test", "20", "10", "2"],
        ["Service", "18", "12", "2"],
        ["Promotion", "22", "8", "1"],
        ["Air condition check", "3", "7", "1"],
        ["Furniture installation", "11", "8", "1"]
    ]
    let colors = [UIColor(red: 0.314, green: 0.698, blue: 0.337, alpha: 1),
                  UIColor(red: 1.000, green: 0.718, blue: 0.298, alpha: 1),
                  UIColor(red: 0.180, green: 0.671, blue: 0.796, alpha: 1)]

    override func viewDidLoad() {
        super.viewDidLoad()

        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self

        spreadsheetView.alwaysBounceVertical = true

        let hairline = 1 / UIScreen.main.scale
        spreadsheetView.intercellSpacing = CGSize(width: 0, height: hairline)
        spreadsheetView.gridStyle = .solid(width: hairline, color: .lightGray)

        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        spreadsheetView.register(TaskCell.self, forCellWithReuseIdentifier: String(describing: TaskCell.self))
        spreadsheetView.register(ChartBarCell.self, forCellWithReuseIdentifier: String(describing: ChartBarCell.self))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spreadsheetView.flashScrollIndicators()
    }

    // MARK: DataSource

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 3 + 7 * weeks.count
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 2 + tasks.count
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if case 0 = column {
            return 90
        } else if case 1...2 = column {
            return 50
        } else {
            return 50
        }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0...1 = row {
            return 28
        } else {
            return 34
        }
    }

    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 3
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 2
    }

    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        let titleHeader = [CellRange(from: (0, 0), to: (1, 0)),
                           CellRange(from: (0, 1), to: (1, 1)),
                           CellRange(from: (0, 2), to: (1, 2))]
        let weakHeader = weeks.enumerated().map { (index, _) -> CellRange in
            return CellRange(from: (0, index * 7 + 3), to: (0, index * 7 + 9))
        }
        let charts = tasks.enumerated().map { (index, task) -> CellRange in
            let start = Int(task[1])!
            let end = Int(task[2])!
            return CellRange(from: (index + 2, start + 2), to: (index + 2, start + end + 2))
        }
        return titleHeader + weakHeader + charts
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        switch (indexPath.column, indexPath.row) {
        case (0, 0):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = "Task"
            cell.gridlines.left = .none
            cell.gridlines.right = .none
            return cell
        case (1, 0):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = "Start"
            cell.gridlines.left = .none
            cell.gridlines.right = .none
            return cell
        case (2, 0):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = "Duration"
            cell.label.textColor = .gray
            cell.gridlines.left = .none
            cell.gridlines.right = .default
            return cell
        case (3..<(3 + 7 * weeks.count), 0):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = weeks[(indexPath.column - 3) / 7]
            cell.gridlines.left = .default
            cell.gridlines.right = .default
            return cell
        case (3..<(3 + 7 * weeks.count), 1):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = String(format: "%02d Apr", indexPath.column - 2)
            cell.gridlines.left = .default
            cell.gridlines.right = .default
            return cell
        case (0, 2..<(2 + tasks.count)):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TaskCell.self), for: indexPath) as! TaskCell
            cell.label.text = tasks[indexPath.row - 2][0]
            cell.gridlines.left = .none
            cell.gridlines.right = .none
            return cell
        case (1, 2..<(2 + tasks.count)):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            cell.label.text = String(format: "April %02d", Int(tasks[indexPath.row - 2][1])!)
            cell.gridlines.left = .none
            cell.gridlines.right = .none
            return cell
        case (2, 2..<(2 + tasks.count)):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            cell.label.text = tasks[indexPath.row - 2][2]
            cell.gridlines.left = .none
            cell.gridlines.right = .none
            return cell
        case (3..<(3 + 7 * weeks.count), 2..<(2 + tasks.count)):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ChartBarCell.self), for: indexPath) as! ChartBarCell
            let start = Int(tasks[indexPath.row - 2][1])!
            if start == indexPath.column - 2 {
                cell.label.text = tasks[indexPath.row - 2][0]
                let colorIndex = Int(tasks[indexPath.row - 2][3])!
                cell.color = colors[colorIndex]
            } else {
                cell.label.text = ""
                cell.color = .clear
            }
            return cell
        default:
            return nil
        }
    }

    /// Delegate

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: (row: \(indexPath.row), column: \(indexPath.column))")
    }
}

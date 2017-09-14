//
//  ViewController.swift
//  TV
//
//  Created by Kishikawa Katsumi on 2017/09/13.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class ViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    @IBOutlet weak var spreadsheetView: SpreadsheetView!

    let channels = [
        "ABC", "NNN", "BBC", "J-Sports", "OK News", "SSS", "Apple", "CUK", "KKR", "APAR",
        "SU", "CCC", "Game", "Anime", "Tokyo NX", "NYC", "SAN", "Drama", "Hobby", "Music"]

    let numberOfRows = 24 * 60 + 1
    var slotInfo = [IndexPath: (Int, Int)]()

    let hourFormatter = DateFormatter()
    let twelveHourFormatter = DateFormatter()

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self

        spreadsheetView.register(HourCell.self, forCellWithReuseIdentifier: String(describing: HourCell.self))
        spreadsheetView.register(ChannelCell.self, forCellWithReuseIdentifier: String(describing: ChannelCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: SlotCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SlotCell.self))
        spreadsheetView.register(BlankCell.self, forCellWithReuseIdentifier: String(describing: BlankCell.self))

//        spreadsheetView.backgroundColor = .black

        let hairline = 1 / UIScreen.main.scale
        spreadsheetView.intercellSpacing = CGSize(width: hairline, height: hairline)
        spreadsheetView.gridStyle = .solid(width: hairline, color: .lightGray)
        spreadsheetView.circularScrolling = CircularScrolling.Configuration.horizontally.rowHeaderStartsFirstColumn

        hourFormatter.calendar = Calendar(identifier: .gregorian)
        hourFormatter.locale = Locale(identifier: "en_US_POSIX")
        hourFormatter.dateFormat = "h\na"

        twelveHourFormatter.calendar = Calendar(identifier: .gregorian)
        twelveHourFormatter.locale = Locale(identifier: "en_US_POSIX")
        twelveHourFormatter.dateFormat = "H"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spreadsheetView.flashScrollIndicators()
    }

    // MARK: DataSource

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return channels.count + 1
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return numberOfRows
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 {
            return 30
        }
        return 130
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if row == 0 {
            return 44
        }
        return 2
    }

    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        var mergedCells = [CellRange]()

        for row in 0..<24 {
            mergedCells.append(CellRange(from: (60 * row + 1, 0), to: (60 * (row + 1), 0)))
        }

        let seeds = [5, 10, 20, 20, 30, 30, 30, 30, 40, 40, 50, 50, 60, 60, 60, 60, 90, 90, 90, 90, 120, 120, 120]
        for (index, _) in channels.enumerated() {
            var minutes = 0
            while minutes < 24 * 60 {
                let duration = seeds[Int(arc4random_uniform(UInt32(seeds.count)))]
                guard minutes + duration + 1 < numberOfRows else {
                    mergedCells.append(CellRange(from: (minutes + 1, index + 1), to: (numberOfRows - 1, index + 1)))
                    break
                }
                let cellRange = CellRange(from: (minutes + 1, index + 1), to: (minutes + duration + 1, index + 1))
                mergedCells.append(cellRange)
                slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = (minutes, duration)
                minutes += duration + 1
            }
        }
        return mergedCells
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.column == 0 && indexPath.row == 0 {
            return nil
        }

        if indexPath.column == 0 && indexPath.row > 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HourCell.self), for: indexPath) as! HourCell
            cell.label.text = hourFormatter.string(from: twelveHourFormatter.date(from: "\((indexPath.row - 1) / 60 % 24)")!)
            cell.gridlines.top = .solid(width: 1, color: .white)
            cell.gridlines.bottom = .solid(width: 1, color: .white)
            return cell
        }
        if indexPath.column > 0 && indexPath.row == 0 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ChannelCell.self), for: indexPath) as! ChannelCell
            cell.label.text = channels[indexPath.column - 1]
            cell.gridlines.top = .solid(width: 1, color: .black)
            cell.gridlines.bottom = .solid(width: 1, color: .black)
            cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
            cell.gridlines.right = cell.gridlines.left
            return cell
        }

        if let (minutes, duration) = slotInfo[indexPath] {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: SlotCell.self), for: indexPath) as! SlotCell
            cell.minutes = minutes % 60
            cell.title = "Dummy Text"
            cell.tableHighlight = duration > 20 ? "Lorem ipsum dolor sit amet, consectetur adipiscing elit" : ""
            return cell
        }
        return spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: BlankCell.self), for: indexPath)
    }

    /// Delegate

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: (row: \(indexPath.row), column: \(indexPath.column))")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        spreadsheetView.setContentOffset(.zero, animated: false)
    }
}

class HourCell: Cell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = bounds

        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.backgroundColor = UIColor(red: 0.220, green: 0.471, blue: 0.871, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2

        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var canBecomeFocused: Bool {
        return false
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if isFocused {
            backgroundColor = .white
        } else {
            backgroundColor = .clear
        }
    }
}

class ChannelCell: Cell {
    let label = UILabel()

    var channel = "" {
        didSet {
            label.text = String(channel)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.backgroundColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 2

        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var canBecomeFocused: Bool {
        return false
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if isFocused {
            backgroundColor = .white
        } else {
            backgroundColor = .clear
        }
    }
}

class SlotCell: Cell {
    @IBOutlet private weak var minutesLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableHighlightLabel: UILabel!

    var minutes = 0 {
        didSet {
            minutesLabel.text = String(format: "%02d", minutes)
        }
    }
    var title = "" {
        didSet {
            titleLabel.text = title
        }
    }
    var tableHighlight = "" {
        didSet {
            tableHighlightLabel.text = tableHighlight
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if isFocused {
            backgroundColor = .white
        } else {
            backgroundColor = .clear
        }
    }
}

class BlankCell: Cell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.9, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var canBecomeFocused: Bool {
        return false
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if isFocused {
            backgroundColor = .white
        } else {
            backgroundColor = .clear
        }
    }
}

struct Table {
    var slots = [String: [Slot]]()

    mutating func add(slot: Slot) {
        let slots = self[slot.channelId]
        if var slots = slots {
            slots.append(slot)
            self[slot.channelId] = slots
        } else {
            var slots = [Slot]()
            slots.append(slot)
            self[slot.channelId] = slots
        }
    }

    subscript(key: String) -> [Slot]? {
        get {
            return slots[key]
        }
        set(newValue) {
            return slots[key] = newValue
        }
    }
}

struct Channel {
    let id: String
    let name: String
    let order: Int
}

struct Slot {
    let id: String
    let title: String
    let startAt: Int
    let endAt: Int
    let tableHighlight: String
    let channelId: String
}

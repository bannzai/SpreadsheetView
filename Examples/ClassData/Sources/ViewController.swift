//
//  ViewController.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/18/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class ViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
  
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
  
    var header = [String]()
    var data = [[String]]()

    enum Sorting {
      
        case ascending
        case descending

        var icon: UIImage? {
            switch self {
            case .ascending:
                return UIImage(named: "sortUp")
            case .descending:
                return UIImage(named: "sortDown")
            }
        }
    }
  
    var sortedColumn = (column: 0, sorting: Sorting.ascending)

    override func viewDidLoad() {
        super.viewDidLoad()
        spreadsheetView.gridStyle = .none
      
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self

        spreadsheetView.register(UINib(nibName: "TotalCell", bundle: nil), forCellWithReuseIdentifier: "TotalCell")
        spreadsheetView.register(UINib(nibName: "TotalCellRight", bundle: nil), forCellWithReuseIdentifier: "TotalCellRight")
        spreadsheetView.register(UINib(nibName: "DataCell", bundle: nil), forCellWithReuseIdentifier: "DataCell")
        spreadsheetView.register(UINib(nibName: "DataCellRight", bundle: nil), forCellWithReuseIdentifier: "DataCellRight")
        spreadsheetView.register(UINib(nibName: "HeaderCell", bundle: nil), forCellWithReuseIdentifier: "HeaderCell")
        spreadsheetView.register(UINib(nibName: "HeaderCellRight", bundle: nil), forCellWithReuseIdentifier: "HeaderCellRight")

        let data = try! String(contentsOf: Bundle.main.url(forResource: "data", withExtension: "tsv")!, encoding: .utf8)
            .components(separatedBy: "\r\n")
            .map { $0.components(separatedBy: "\t") }
        header = data[0]
      
        header[1] = "Gender,\nyrs"
      
        self.data = Array(data.dropFirst())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        spreadsheetView.flashScrollIndicators()
    }

    // MARK: DataSource

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + data.count
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
      switch column {
      case 0:
        return 200
      case header.count - 1, header.count - 2:
        return 100
      default:
        return 160
      }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
      switch row {
      case 0, 1:
        return 60
      default:
        return 48
      }
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 2
    }
  
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
      return 1
    }
  
    func frozenColumnsRight(in spreadsheetView: SpreadsheetView) -> Int {
      return 2
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
      switch indexPath.row {
      case 0:
        var identifier = "HeaderCell"
        
        if indexPath.column > 0 {
          identifier = "HeaderCellRight"
        }
        
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! HeaderCell
        
        cell.label?.text = header[indexPath.column]
        
        if case indexPath.column = sortedColumn.column {
          cell.sortArrow?.image = sortedColumn.sorting.icon
          cell.labelTrailingConstraint?.constant = 32
          cell.label?.textColor = UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        } else {
          cell.labelTrailingConstraint?.constant = 8
          cell.sortArrow?.image = nil
          cell.label?.textColor = UIColor.black
        }
        
        cell.gridlines.top = .solid(width: CGFloat(1), color: UIColor.white)
        cell.gridlines.left = .solid(width: CGFloat(1), color: UIColor.white)
        cell.gridlines.bottom = .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1))
        cell.gridlines.right = .solid(width: CGFloat(1), color: UIColor.white)
        
        cell.setNeedsLayout()
        
        return cell
      case 1:
        var identifier = "TotalCell"
        
        if indexPath.column > 0 {
          identifier = "TotalCellRight"
        }
        
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TotalCell
        cell.label?.text = data[indexPath.row - 1][indexPath.column]
        
        cell.gridlines.top = .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1))
        cell.gridlines.left = .solid(width: CGFloat(1), color: UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1))
        cell.gridlines.bottom = .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1))
        cell.gridlines.right = .solid(width: CGFloat(1), color: UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1))
        
        return cell
      default:
        var identifier = "DataCell"
        
        if indexPath.column > 0 {
          identifier = "DataCellRight"
        }
        
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DataCell
        cell.label?.text = data[indexPath.row - 1][indexPath.column]
        
        cell.gridlines.top = .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1))
        cell.gridlines.left = .solid(width: CGFloat(1), color: UIColor.white)
        cell.gridlines.bottom = .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1))
        cell.gridlines.right = .solid(width: CGFloat(1), color: UIColor.white)
        
        return cell
      }
    }

    /// Delegate

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if case 0 = indexPath.row {
            if sortedColumn.column == indexPath.column {
                sortedColumn.sorting = sortedColumn.sorting == .ascending ? .descending : .ascending
            } else {
                sortedColumn = (indexPath.column, .ascending)
            }
            data.sort {
                let ascending = $0[sortedColumn.column] < $1[sortedColumn.column]
                return sortedColumn.sorting == .ascending ? ascending : !ascending
            }
            spreadsheetView.reloadData()
        }
    }
}

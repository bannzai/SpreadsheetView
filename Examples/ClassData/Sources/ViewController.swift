//
//  ViewController.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/18/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class Data {
  var columnTitles = [String]()
  var items = [Data]()
  var isExpanded = false
  
  init(columnTitles: [String] = [], items:[Data] = []) {
    self.columnTitles = columnTitles
    self.items = items
  }
}

class ViewController: UIViewController, SpreadsheetExpandableViewDataSource, SpreadsheetExpandableViewDelegate {
  
    func spreadsheetView(_ spreadsheetView: SpreadsheetExpandableView, didSelectItemAt indexPath: IndexPath, for subrow: Int) {
      print("didSelectItemAt indexPath:\(indexPath) for subrow:\(subrow)")
    }
 
    func spreadsheetView(_ spreadsheetView: SpreadsheetExpandableView, heightForSubrow subrow: Int, in row: Int) -> CGFloat {
      return 48
    }
  
    func numberOfSubrows(in spreadsheetView: SpreadsheetExpandableView, for row: Int) -> Int {
      switch row {
      case 0:
        return 0
      case 1:
        return 10
      case 2:
        return 8
      default:
        return 15
      }
    }
  
    func spreadsheetView(_ spreadsheetView: SpreadsheetExpandableView, isItemExpandedAt row: Int) -> Bool {
      return false
    }
  
    func spreadsheetView(_ spreadsheetView: SpreadsheetExpandableView, cellForItemIn subrow: Int, at indexPath: IndexPath) -> Cell? {
      var identifier = "DataCell"
      
      if indexPath.column > 0 {
        identifier = "DataCellRight"
      }
      
      let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DataCell
      cell.label?.textColor = UIColor.black
      cell.label?.text = data[indexPath.row - 1].items[0].columnTitles[0]
      //cell.backgroundColor = UIColor.clear
      
      cell.gridlines.top = subrow > 0 ? .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1)) : .solid(width: CGFloat(1), color: UIColor.white)
      cell.gridlines.left = .solid(width: CGFloat(1), color: UIColor.white)
      cell.gridlines.bottom = .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1))
      cell.gridlines.right = .solid(width: CGFloat(1), color: UIColor.white)
      
      cell.setNeedsLayout()
      
      return cell
    }
  
  // MARK: - index methods
  
  func data(for rowIndex: Int) -> Data {
    var rowArray: [Data] = []
    for dataRow in data {
      rowArray.append(dataRow)
      if dataRow.isExpanded {
        rowArray.append(contentsOf: dataRow.items)
      }
    }
    
    //print("data for rowIndex \(rowIndex) = \(rowArray[rowIndex].columnTitles)")
    return rowArray[rowIndex]
  }
  
  var dataRowsCount: Int {
    var count = data.count
    for row in data {
      if row.isExpanded {
        count += row.items.count
      }
    }
    //print("dataRowsCount \(count)")
    
    return count
  }
  
  
    @IBOutlet weak var spreadsheetView: SpreadsheetExpandableView!
  
    var header = [String]()
    var data = [Data]()

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

        var raw = try! String(contentsOf: Bundle.main.url(forResource: "data", withExtension: "tsv")!, encoding: .utf8)
            .components(separatedBy: "\r\n")
            .map { $0.components(separatedBy: "\t") }
        header = raw[0]
      
        header[1] = "Gender,\nyrs"
      
      raw = Array(raw.dropFirst())
      
      data = [Data]()
      for item in raw {
        let items = [Data(columnTitles: item.map({ "sub \($0)" }), items: [])]
        self.data.append(Data(columnTitles: item, items: items))
      }
      
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
      default:
        return 180
      }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
      switch row {
      case 0:
        return 60
      default:
        return 48
      }
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
  
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
      return 1
    }
  
    func frozenColumnsRight(in spreadsheetView: SpreadsheetView) -> Int {
      return 1
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
      switch indexPath.row {
      case 0:
        var identifier = "HeaderCell"
        
        if indexPath.column > 0 {
          identifier = "HeaderCellRight"
        }
        
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! HeaderCell
        cell.label?.textColor = UIColor.black
        cell.label?.text = header[indexPath.column]
        //cell.backgroundColor = UIColor.clear  
        
        if case indexPath.column = sortedColumn.column {
          cell.sorting = sortedColumn.sorting
          cell.label?.textColor = UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        } else {
          cell.sorting = .none
          cell.label?.textColor = UIColor.black
        }
        
        cell.gridlines.top = .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1))
        cell.gridlines.left = .solid(width: CGFloat(1), color: UIColor.white)
        cell.gridlines.bottom = .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1))
        cell.gridlines.right = .solid(width: CGFloat(1), color: UIColor.white)
        
        cell.setNeedsLayout()
        
        return cell
      default:
        var identifier = "DataCell"
        
        if indexPath.column > 0 {
          identifier = "DataCellRight"
        }
        
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DataCell
        cell.label?.textColor = UIColor.black
        cell.label?.text = data[indexPath.row - 1].columnTitles[0]
        
        cell.gridlines.top = .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1))
        cell.gridlines.left = .solid(width: CGFloat(1), color: UIColor.white)
        cell.gridlines.bottom = .solid(width: CGFloat(0.5), color: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1))
        cell.gridlines.right = .solid(width: CGFloat(1), color: UIColor.white)
        
        cell.setNeedsLayout()
        
        return cell
      }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if case 0 = indexPath.row {
            if sortedColumn.column == indexPath.column {
                sortedColumn.sorting = sortedColumn.sorting == .ascending ? .descending : .ascending
            } else {
                sortedColumn = (indexPath.column, .ascending)
            }
            data.sort {
                let ascending = $0.columnTitles[sortedColumn.column] < $1.columnTitles[sortedColumn.column]
                return sortedColumn.sorting == .ascending ? ascending : !ascending
            }
            spreadsheetView.reloadData()
        } else {
          ///expand/collapse
          let rowData = data[indexPath.row - 1]
          rowData.isExpanded = !rowData.isExpanded
          spreadsheetView.reloadData()
      }
    }
}

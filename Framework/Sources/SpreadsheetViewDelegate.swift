//
//  SpreadsheetViewDelegate.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/21/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

/// The `SpreadsheetViewDelegate` protocol defines methods that allow you to manage the selection and
/// highlighting of cells in a spreadsheet view and to perform actions on those cells.
/// The methods of this protocol are all optional.
public protocol SpreadsheetViewDelegate: class {
    /// Asks the delegate if the cell should be highlighted during tracking.
    /// - Note: As touch events arrive, the spreadsheet view highlights cells in anticipation of the user selecting them.
    ///   As it processes those touch events, the collection view calls this method to ask your delegate if a given cell should be highlighted.
    ///   It calls this method only in response to user interactions and does not call it if you programmatically set the highlighting on a cell.
    ///
    ///   If you do not implement this method, the default return value is `true`.
    ///
    /// - Parameters:
    ///   - spreadsheetView: The spreadsheet view object that is asking about the highlight change.
    ///   - indexPath: The index path of the cell to be highlighted.
    /// - Returns: `true` if the item should be highlighted or `false` if it should not.
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
    /// Tells the delegate that the cell at the specified index path was highlighted.
    /// - Note: The spreadsheet view calls this method only in response to user interactions and does not call it
    ///   if you programmatically set the highlighting on a cell.
    ///
    /// - Parameters:
    ///   - spreadsheetView: The spreadsheet view object that is notifying you of the highlight change.
    ///   - indexPath: The index path of the cell that was highlighted.
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didHighlightItemAt indexPath: IndexPath)
    /// Tells the delegate that the highlight was removed from the cell at the specified index path.
    /// - Note: The spreadsheet view calls this method only in response to user interactions and does not call it
    ///   if you programmatically change the highlighting on a cell.
    ///
    /// - Parameters:
    ///   - spreadsheetView: The spreadsheet view object that is notifying you of the highlight change.
    ///   - indexPath: The index path of the cell that had its highlight removed.
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didUnhighlightItemAt indexPath: IndexPath)
    /// Asks the delegate if the specified cell should be selected.
    /// - Note: The spreadsheet view calls this method when the user tries to select an item in the collection view.
    ///   It does not call this method when you programmatically set the selection.
    ///
    ///   If you do not implement this method, the default return value is `true`.
    ///
    /// - Parameters:
    ///   - spreadsheetView: The spreadsheet view object that is asking whether the selection should change.
    ///   - indexPath: The index path of the cell to be selected.
    /// - Returns: `true` if the item should be selected or `false` if it should not.
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    /// Asks the delegate if the specified item should be deselected.
    /// - Note: The spreadsheet view calls this method when the user tries to deselect a cell in the spreadsheet view.
    ///   It does not call this method when you programmatically deselect items.
    ///
    ///   If you do not implement this method, the default return value is `true`.
    ///
    ///   This method is called when the user taps on an already-selected item in multi-select mode
    ///
    /// - Parameters:
    ///   - spreadsheetView: The spreadsheet view object that is asking whether the selection should change.
    ///   - indexPath: The index path of the cell to be deselected.
    /// - Returns: `true` if the cell should be deselected or `false` if it should not.
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldDeselectItemAt indexPath: IndexPath) -> Bool
    /// Tells the delegate that the cell at the specified index path was selected.
    /// - Note: The spreadsheet view calls this method when the user successfully selects a cell in the spreadsheet view.
    ///   It does not call this method when you programmatically set the selection.
    ///
    /// - Parameters:
    ///   - spreadsheetView: The spreadsheet view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath)
    /// Tells the delegate that the cell at the specified path was deselected.
    /// - Note: The spreadsheet view calls this method when the user successfully deselects an item in the spreadsheet view.
    ///   It does not call this method when you programmatically deselect items.
    ///
    /// - Parameters:
    ///   - spreadsheetView: The spreadsheet view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was deselected.
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didDeselectItemAt indexPath: IndexPath)
}

extension SpreadsheetViewDelegate {
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldHighlightItemAt indexPath: IndexPath) -> Bool { return true }
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, didHighlightItemAt indexPath: IndexPath) {}
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, didUnhighlightItemAt indexPath: IndexPath) {}
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return true }
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldDeselectItemAt indexPath: IndexPath) -> Bool { return true }
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {}
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, didDeselectItemAt indexPath: IndexPath) {}
}

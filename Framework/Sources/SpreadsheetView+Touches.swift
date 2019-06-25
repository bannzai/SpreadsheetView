//
//  SpreadsheetView+Touches.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/1/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

extension SpreadsheetView {
    func touchesBegan(_ touches: Set<UITouch>, _ event: UIEvent?) {
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

    func touchesEnded(_ touches: Set<UITouch>, _ event: UIEvent?) {
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

    func touchesCancelled(_ touches: Set<UITouch>, _ event: UIEvent?) {
        unhighlightAllItems()
        perform(#selector(restorePreviousSelection), with: touches, afterDelay: 0)
        perform(#selector(clearCurrentTouch), with: nil, afterDelay: 0)
    }

    func highlightItems(on touches: Set<UITouch>) {
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

    private func deselectAllItems() {
        selectedIndexPaths.forEach { deselectItem(at: $0) }
    }

    @objc func restorePreviousSelection() {
        selectedIndexPaths.forEach {
            cellsForItem(at: $0).forEach { $0.isSelected = true }
        }
    }

    @objc func clearCurrentTouch() {
        currentTouch = nil
    }
}

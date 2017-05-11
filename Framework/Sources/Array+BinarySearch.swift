//
//  Array+BinarySearch.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/23/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    func insertionIndex(of element: Element) -> Int {
        var lower = 0
        var upper = count - 1
        while lower <= upper {
            let middle = (lower + upper) / 2
            if self[middle] < element {
                lower = middle + 1
            } else if element < self[middle] {
                upper = middle - 1
            } else {
                return middle
            }
        }
        return lower
    }
}

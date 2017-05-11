//
//  Models.swift
//  SpreadsheetView
//
//  Created by kishikawakatsumi on 5/11/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

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

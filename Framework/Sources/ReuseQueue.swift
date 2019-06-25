//
//  ReuseQueue.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/16/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import Foundation

final class ReuseQueue<Reusable> where Reusable: NSObject {
    var reusableObjects = Set<Reusable>()

    func enqueue(_ reusableObject: Reusable) {
        reusableObjects.insert(reusableObject)
    }

    func dequeue() -> Reusable? {
        if let _ = reusableObjects.first {
            return reusableObjects.removeFirst()
        }
        return nil
    }

    func dequeueOrCreate() -> Reusable {
        if let _ = reusableObjects.first {
            return reusableObjects.removeFirst()
        }
        return Reusable()
    }
}

final class ReusableCollection<Reusable>: Sequence where Reusable: NSObject {
    var pairs = [Address: Reusable]()
    var addresses = Set<Address>()

    func contains(_ member: Address) -> Bool {
        return addresses.contains(member)
    }

    @discardableResult
    func insert(_ newMember: Address) -> (inserted: Bool, memberAfterInsert: Address) {
        return addresses.insert(newMember)
    }

    func subtract(_ other: Set<Address>) {
        addresses.subtract(other)
    }

    subscript(key: Address) -> Reusable? {
        get {
            return pairs[key]
        }
        set(newValue) {
            pairs[key] = newValue
        }
    }

    func makeIterator() -> AnyIterator<Reusable> {
        return AnyIterator(pairs.values.makeIterator())
    }
}

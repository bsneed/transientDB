//
//  DataStore.swift
//
//
//  Created by Brandon Sneed on 11/27/23.
//

import Foundation

public enum DataChore {
    case keep
    case discard
}

public struct DataResult {
    let count: Int
    let data: Data
}

public protocol DataStore {
    associatedtype StoreConfiguration
    typealias Completion = (DataResult) -> DataChore
    var hasData: Bool { get }
    var count: Int { get }
    init(configuration: StoreConfiguration)
    func append<T: Codable>(data: T)
    func fetch(count: Int?, maxBytes: Int?) -> DataResult
    func remove(count: Int)
}


//
//  File.swift
//  
//
//  Created by Brandon Sneed on 11/27/23.
//

import Foundation

public class MemoryStore: DataStore {
    public typealias StoreConfiguration = Configuration
    public struct Configuration {
        // nothing
    }
    
    internal var items = [Data]()
    
    public var hasData: Bool {
        return (items.count > 0)
    }
    
    public var count: Int {
        return items.count
    }
    
    public required init(configuration: Configuration) {
        // <Pink Floyd> we don't need no ... configggguration
    }
    
    public func append<T: Codable>(data: T) {
        let encoder = JSONEncoder()
        guard let d = try? encoder.encode(data) else { return }
        items.append(d)
    }
    
    public func fetch(count: Int?, maxBytes: Int?) -> DataResult {
        var accumulatedCount = 0
        var accumulatedData = Data()
        
        for item in items {
            if let maxBytes, accumulatedData.count + item.count > maxBytes {
                break
            }
            if let count, accumulatedCount >= count {
                break
            }
            accumulatedCount += 1
            accumulatedData.append(item)
        }
        
        return DataResult(count: accumulatedCount, data: accumulatedData)
    }
    
    public func remove(count: Int) {
        let range = 0..<count
        items.removeSubrange(range)
    }
}


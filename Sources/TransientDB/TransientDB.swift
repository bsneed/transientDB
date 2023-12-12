//
//  TransientDB.swift
//
//
//  Created by Brandon Sneed on 11/27/23.
//
import Foundation

public class TransientDB<T: DataStore> {
    // our data store
    internal let store: any DataStore
    // keeps items added in the order given.
    internal let syncQueue = DispatchQueue(label: "transientDB.sync")
    // makes accessing count safe and mostly accurate.
    internal let countLock = NSLock()
    
    public var hasData: Bool {
        countLock.lock()
        defer { countLock.unlock() }
        return store.hasData
    }
    
    public var count: Int {
        countLock.lock()
        defer { countLock.unlock() }
        return store.count
    }
    
    public init(configuration: T.StoreConfiguration) {
        self.store = T.init(configuration: configuration)
    }
    
    public func append(data: Codable) {
        syncQueue.sync {
            countLock.lock()
            store.append(data: data)
            countLock.unlock()
        }
    }
    
    public func fetch(count: Int? = nil, maxBytes: Int? = nil, completion: @escaping T.Completion) {
        syncQueue.sync { [weak self] in
            guard let self else { return }
            let result = store.fetch(count: count, maxBytes: maxBytes)
            let action = completion(result)
            switch action {
            case .keep:
                // <Madonna> But I made up my mind .. I'm keeping the babies ..
                break
            case .discard:
                // pour one for the now dead homies ...
                countLock.lock()
                store.remove(count: result.count)
                countLock.unlock()
            }
        }
    }
}

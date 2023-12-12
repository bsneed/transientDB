//
//  File.swift
//  
//
//  Created by Brandon Sneed on 11/27/23.
//

import Foundation

public class FileStore: DataStore {
    public typealias StoreConfiguration = Configuration
    public struct Configuration {
        let storageLocation: URL
        let filename: String
    }
    
    internal var writer: LineStreamWriter?
    internal var fileURL: URL
    
    public var hasData: Bool {
        var result = false
        if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path) {
            result = ((attrs[FileAttributeKey.size] as? Int ?? 0) > 0)
        }
        return result
    }
    
    public var count: Int {
        var result = 0
        let reader = LineStreamReader(url: self.fileURL)
        while let _ = reader?.readLine() {
            result += 1
        }
        return result
    }
    
    public required init(configuration: Configuration) {
        let url = configuration.storageLocation.appendingPathComponent(configuration.filename)
        self.fileURL = url
        self.writer = LineStreamWriter(url: url)
    }
    
    public func append<T: Codable>(data: T) {
        guard let writer else { return }
        let encoder = JSONEncoder()
        guard let d = try? encoder.encode(data) else { return }
        guard let line = String(data: d, encoding: .utf8) else { return }
        do {
            try writer.writeLine(line + ",")
        } catch {
            print(error)
        }
    }
    
    public func fetch(count: Int?, maxBytes: Int?) -> DataResult {
        var accumulatedCount = 0
        var accumulatedData = Data()
        
        let reader = LineStreamReader(url: self.fileURL)
        
        while let item = reader?.readLine() {
            if let maxBytes, accumulatedData.count + item.lengthOfBytes(using: .utf8) > maxBytes {
                break
            }
            if let count, accumulatedCount >= count {
                break
            }
            if let data = item.data(using: .utf8) {
                accumulatedCount += 1
                accumulatedData.append(data)
            }
        }
        
        return DataResult(count: accumulatedCount, data: accumulatedData)
    }
    
    public func remove(count: Int) {
        // close existing writer
        writer = nil
        
        let outputURL = self.fileURL.appendingPathExtension("tmp")
        var reader = LineStreamReader(url: self.fileURL)
        var newWriter = LineStreamWriter(url: outputURL)
        
        // get x (count) # of items in ...
        var readCount = 0
        while let _ = reader?.readLine() {
            if readCount >= count-1 {
                break
            }
            readCount += 1
        }
        // output the rest to the new file
        while let line = reader?.readLine() {
            do {
                try newWriter?.writeLine(line)
            } catch {
                print(error)
            }
        }
        
        // close everything
        reader = nil
        newWriter = nil
        
        try? FileManager.default.removeItem(at: self.fileURL)
        try? FileManager.default.moveItem(at: outputURL, to: self.fileURL)
        
        writer = LineStreamWriter(url: self.fileURL)
    }
}



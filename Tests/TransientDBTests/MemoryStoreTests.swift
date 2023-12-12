import XCTest
@testable import TransientDB

final class MemoryStoreTests: XCTestCase {
    func testWorkingWithAll() throws {
        let db = TransientDB<MemoryStore>(configuration: MemoryStore.StoreConfiguration())
        
        for i in 0..<10000 {
            // pad to give everything an identical size
            db.append(data: "entry \(i.description.padding(toLength: 6, withPad: "0", startingAt: 0))")
        }
        
        var finished = false
        db.fetch { result in
            XCTAssertTrue(result.count == 10000)
            print("fetched \(result.data.count) bytes.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                finished = true
            }
            return .keep
        }
        
        while !finished {
            RunLoop.main.run(until: Date.distantPast)
        }
        
        XCTAssertTrue(db.hasData)
        
        finished = false
        db.fetch { result in
            XCTAssertTrue(result.count == 10000)
            print("fetched \(result.data.count) bytes.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                finished = true
            }
            return .discard
        }
        
        while !finished {
            RunLoop.main.run(until: Date.distantPast)
        }
        
        XCTAssertFalse(db.hasData)
    }
    
    func testWorkingWithCount() throws {
        let db = TransientDB<MemoryStore>(configuration: MemoryStore.StoreConfiguration())
        
        for i in 0..<10000 {
            db.append(data: "entry \(i)")
        }
        
        var finished = false
        db.fetch(count: 5000) { result in
            XCTAssertTrue(result.count == 5000)
            print("fetched \(result.data.count) bytes.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                finished = true
            }
            return .keep
        }
        
        while !finished {
            RunLoop.main.run(until: Date.distantPast)
        }
        
        XCTAssertTrue(db.hasData)
        
        finished = false
        db.fetch(count: 5000) { result in
            XCTAssertTrue(result.count == 5000)
            print("fetched \(result.data.count) bytes.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                finished = true
            }
            return .discard
        }
        
        while !finished {
            RunLoop.main.run(until: Date.distantPast)
        }
        
        XCTAssertFalse(db.hasData)
    }
    
    func testWorkingWithSize() throws {
        let db = TransientDB<MemoryStore>(configuration: MemoryStore.StoreConfiguration())
        
        for i in 0..<10000 {
            db.append(data: "entry \(i)")
        }
        
        var finished = false
        db.fetch(maxBytes: 58000) { result in
            XCTAssertTrue(result.count == 4925)
            XCTAssertTrue(result.data.count == 57990)
            print("fetched \(result.data.count) bytes.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                finished = true
            }
            return .keep
        }
        
        while !finished {
            RunLoop.main.run(until: Date.distantPast)
        }
        
        XCTAssertTrue(db.hasData)
        
        finished = false
        db.fetch(maxBytes: 57990) { result in
            XCTAssertTrue(result.count == 4925)
            XCTAssertTrue(result.data.count == 57990)
            print("fetched \(result.data.count) bytes.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                finished = true
            }
            return .discard
        }
        
        while !finished {
            RunLoop.main.run(until: Date.distantPast)
        }
        
        XCTAssertTrue(db.hasData)
    }

    func testWorkingWithCountAndSize() throws {
        let db = TransientDB<MemoryStore>(configuration: MemoryStore.StoreConfiguration())
        
        for i in 0..<10000 {
            // 14 bytes
            db.append(data: "entry \(i.description.padding(toLength: 6, withPad: "0", startingAt: 0))")
        }
        
        var finished = false
        db.fetch(count: 3, maxBytes: 43) { result in
            XCTAssertTrue(result.count == 3)
            XCTAssertTrue(result.data.count == 42)
            print("fetched \(result.data.count) bytes.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                finished = true
            }
            return .keep
        }
        
        while !finished {
            RunLoop.main.run(until: Date.distantPast)
        }
        
        XCTAssertTrue(db.hasData)
        
        finished = false
        db.fetch(count: 3, maxBytes: 40) { result in
            XCTAssertTrue(result.count == 2)
            XCTAssertTrue(result.data.count == 28)
            print("fetched \(result.data.count) bytes.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                finished = true
            }
            return .discard
        }

        while !finished {
            RunLoop.main.run(until: Date.distantPast)
        }
        
        XCTAssertTrue(db.hasData)
    }

}

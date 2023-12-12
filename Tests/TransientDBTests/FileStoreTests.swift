import XCTest
@testable import TransientDB

struct TestData: Codable {
    let myName: String
    let myText: String
    let myNumber: Double
    let array: [Int]
    let dict: [String: String]
}

final class FileStoreTests: XCTestCase {
    override func setUp() async throws {
        let testLog = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(component: "test.log")
        try? FileManager.default.removeItem(at: testLog)
    }
    
    func testDoNothing() throws {
        
    }
    
    func testWorkingWithAll() throws {
        let db = TransientDB<FileStore>(configuration: FileStore.StoreConfiguration(
            storageLocation: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!,
            filename: "test.log"
        ))
        
        for i in 0..<10000 {
            let t = TestData(
                myName: "entry \(i.description)",
                myText: "This has a \n in it",
                myNumber: 3.14,
                array: [1, 2, 3, 4],
                dict: ["a": "1", "b": "2"]
            )
            db.append(data: t)
        }
        
        db.fetch(maxBytes: 500000) { result in
            sendToSegment(result.data)
            return .discard
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
        XCTAssertEqual(db.count, 0)
    }
    
    func testWorkingWithCount() throws {
        let db = TransientDB<FileStore>(configuration: FileStore.StoreConfiguration(
            storageLocation: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!,
            filename: "test.log"
        ))
        
        for i in 0..<10000 {
            let t = TestData(
                myName: "entry \(i.description)",
                myText: "This has a \n in it",
                myNumber: 3.14,
                array: [1, 2, 3, 4],
                dict: ["a": "1", "b": "2"]
            )
            // pad to give everything an identical size
            db.append(data: t)
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
        db.fetch(count: 9998) { result in
            XCTAssertTrue(result.count == 9998)
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
        XCTAssertEqual(db.count, 2)
    }
    
    /*func testWorkingWithSize() throws {
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
        
        XCTAssertTrue(db.count == 10000)
        
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
        
        XCTAssertTrue(db.count == 5075)
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
        
        XCTAssertTrue(db.count == 10000)
        
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
        
        XCTAssertTrue(db.count == 9998)
    }*/

}

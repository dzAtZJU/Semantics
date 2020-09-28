//
//  SemanticsTests.swift
//  SemanticsTests
//
//  Created by Zhou Wei Ran on 2020/5/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import XCTest
import RealmSwift
@testable import SemanticsB1

class SemanticsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRealmListAPI() throws {
        let list = List<Int>()
        list.append(objectsIn: [1,2,3])
        list.insert(0, at: 0)
        XCTAssert(list.first! == 0, "insert(i) is at before i")
        list.insert(4, at: 4)
        XCTAssert(list.last! == 4, "insert(list.count) is valid")
        
        list.removeAll()
        list.append(objectsIn: [0,1,2])
        list.move(from: 0, to: 2)
        XCTAssert(list.last! == 0, "move(from, to) to is count after from removed")
        list.move(from: 2, to: 0)
        XCTAssert(list.first! == 0, "move(from, to) to is count after from removed")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

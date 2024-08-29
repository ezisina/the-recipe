//
//  UtilTests.swift
//  TheRecipeTests
//
//  Created by Elena Zisina on 11/26/23.
//

import XCTest
@testable import TheRecipe

final class UtilTests: XCTestCase {

    let testCases = ["2":2.0,"½":0.5, "1/2":0.5, "2.0":2.0]
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConversionStringToDouble() throws {
        for (source, expectedRes) in testCases {
            let result = source.numberWFractionsToDouble()
            XCTAssertEqual(result, expectedRes, "'\(source)'")
        }
    }
    func testConversionStringToDouble2() throws {
        let result = "1/2".numberWFractionsToDouble()
        XCTAssertEqual(result, 0.5, "")
        
    }
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

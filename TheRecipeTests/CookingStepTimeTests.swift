//
//  CookingStepTimeTests.swift
//  TheRecipeTests
//
//  Created by Iurii Zisin on 7/8/22.
//

import XCTest
@testable import TheRecipe

final class CookingStepTimeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTimeAssignmentEquality() throws {
        let cookingStep = CookingStep(context: PersistenceController.test.container.viewContext)
        cookingStep.time.hours = 2
        XCTAssertEqual(2, cookingStep.time.hours)
        cookingStep.time.minutes = 2
        XCTAssertEqual(2, cookingStep.time.minutes)
        cookingStep.time.seconds = 2
        XCTAssertEqual(2, cookingStep.time.seconds)

    }
    
    func testTimeAssignmentComponents() throws {
        let cookingStep = CookingStep(context: PersistenceController.test.container.viewContext)
        cookingStep.time.hours = 1
        cookingStep.time.minutes = 1
        cookingStep.time.seconds = 1
        XCTAssertEqual(3_661, cookingStep.time)
    }

    func testTimeAssignmentWholeSeconds() throws {
        let cookingStep = CookingStep(context: PersistenceController.test.container.viewContext)
        cookingStep.time = 89_878
        XCTAssertEqual(24, cookingStep.time.hours)
        XCTAssertEqual(57, cookingStep.time.minutes)
        XCTAssertEqual(58, cookingStep.time.seconds)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

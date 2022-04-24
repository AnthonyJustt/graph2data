//
//  graph2dataUITests.swift
//  graph2dataUITests
//
//  Created by Anton Krivonozhenkov on 12.11.2021.
//

import XCTest

class graph2dataUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // UI tests must launch the application that they test.
        
        let masterScrollViews = app.scrollViews
        let GetDateButton = masterScrollViews.otherElements.buttons["Get Date"]
        
    //    XCTAssertFalse(masterScrollViews.element.exists)
        XCTAssert(GetDateButton.exists)
        
        GetDateButton.tap()
        
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testExample2() throws {
        XCTAssertEqual(app.buttons.matching(identifier: "get_date").firstMatch.label, "Get Date")
    }
    
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}

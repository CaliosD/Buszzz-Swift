//
//  BuszzzUITests.swift
//  BuszzzUITests
//
//  Created by Calios on 5/12/17.
//  Copyright © 2017 Calios. All rights reserved.
//

import XCTest

class BuszzzUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
		setupSnapshot(app)
		app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		
		snapshot("01LocationListScreen")
		let app = XCUIApplication()
		app.navigationBars["Buszzz"].buttons["ic add"].tap()
		app.textFields["请输入搜索地址"].typeText("xitucheng")
		snapshot("02SearchLocationScreen")
		
		let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
		element.tap()
		element.children(matching: .other).element(boundBy: 4).tap()
		app.buttons["确定"].tap()
		snapshot("03EditingLocationScreen")
		
    }
    
}

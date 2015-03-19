

import UIKit
import XCTest


class AllInOneTests: XCTestCase {
    
    //unit test for setup
    override func setUp() {
        super.setUp()
        // This method is called before the invocation of each test method in the class.
    }
    
    //unit test for teardown
    override func tearDown() {
        // This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //unit test for testExample
    func testExample() {
        
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        
        self.measureBlock() {
            
        }
    }
    
    
    
    //unit test -to see if the view loads
        func testViewDidLoad()
        {
            
            let a = SearchViewController()
            
            
            XCTAssertNotNil(a.view, "There is no view loading")
        }
    }





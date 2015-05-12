//
//  ComlinkTests.swift
//  ComlinkTests
//
//  Created by Luca Torella on 12/05/2015.
//  Copyright (c) 2015 blinkbox music. All rights reserved.
//

import UIKit
import XCTest

class ComlinkTests: XCTestCase {

    let groupIdentifier = "test.identifier"
    let directoryName = "directory name"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSendingAndReceivingString() {
//        let sender = ComlinkSender(applicationGroupIdentifier: groupIdentifier, directoryName: directoryName)
//        let receiver = ComlinkReceiver(applicationGroupIdentifier: groupIdentifier, directoryName: directoryName)
//
//        let identifier = "identifier"
//
//        let expectation = expectationWithDescription("expectation")
//
//        class Listener: ComlinkListener {
//            @objc func objectChanged(object: AnyObject) {
//                if let string = object as? String where string == "test" {
//                    expectation.fulfill()
//                } else {
//                    XCTAssert(false, "Didn't receive a string back or the string was wrong")
//                }
//            }
//        }
//
//        receiver.addListener(identifier, listener: Listener())
//
//        sender.sendObject("test", identifier: identifier)
//
//        waitForExpectationsWithTimeout(5, handler: nil)
    }
}

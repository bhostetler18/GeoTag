//
//  GeoTagUI01LaunchTests.swift
//  GeoTagUITests
//
//  Created by Marco S Hyman on 3/27/24.
//

import XCTest

final class GeoTagUI01LaunchTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchEnvironment = ["BACKUP": NSTemporaryDirectory()]

        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the
        // invocation of each test method in the class.
        try super.tearDownWithError()
        app = nil
    }

    func testSetBackup() {
        // do nothing.  A side effect of running the test will set up
        // a backup folder.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

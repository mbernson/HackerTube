//
//  HackerTubeUIScreenshotTests.swift
//  HackerTubeUITests
//
//  Created by Mathijs Bernson on 30/12/2023.
//

import XCTest

@MainActor
final class HackerTubeUIScreenshotTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testRecentTalks() {
        app = XCUIApplication()
        app.launch()
        XCTAssertTrue(
            app.otherElements["TalksGrid"].buttons.firstMatch.waitForExistence(timeout: 3.0))
        wait(forTimeInterval: 2.0)  // Give the app some time to load
        takeScreenshot("RecentTalks")
    }

    func testConferences() {
        app = XCUIApplication()
        app.launch()
        app.buttons["Conferences"].firstMatch.tap()
        XCTAssertTrue(
            app.otherElements["ConferencesGrid"].buttons.firstMatch.waitForExistence(timeout: 3.0))
        wait(forTimeInterval: 2.0)  // Give the app some time to load
        takeScreenshot("Conferences")
    }

    func testVideo() {
        app = XCUIApplication()
        app.launch()
        let firstTalk = app.otherElements["TalksGrid"].buttons.firstMatch
        XCTAssertTrue(firstTalk.waitForExistence(timeout: 5.0))
        firstTalk.tap()
        XCTAssertTrue(app.otherElements["Video"].waitForExistence(timeout: 5))
        app.otherElements["Video"].firstMatch.tap()
        app.buttons["Play/Pause"].firstMatch.tap()
        wait(forTimeInterval: 2.0)
        takeScreenshot("Video")
    }

    private func takeScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func wait(forTimeInterval timeout: TimeInterval) {
        let exp = expectation(description: "Wait for \(timeout) seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: timeout)
        if result != .timedOut {
            XCTFail("Delay interrupted")
        }
    }
}

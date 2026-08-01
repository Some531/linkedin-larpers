import XCTest

/// Smoke tests for the three flows the pitch depends on:
/// 1. first-run language choice (the screen a first-time user must clear),
/// 2. the SMS deep link opening the right alert (the demo's money shot),
/// 3. glossary search finding "storm surge".
///
/// Language is preset via the UserDefaults argument domain
/// (`-appLanguage war`), which overrides the persisted value for that
/// launch only — no state cleanup needed between tests.
final class SmokeTests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testFirstRunLanguageChoiceInWaray() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", ""]
        app.launch()

        let waray = app.buttons["Winaray (Waray)"]
        XCTAssertTrue(waray.waitForExistence(timeout: 5), "Language picker should show on first run")
        waray.tap()

        // After selecting Waray the Continue button re-renders in Waray.
        let continueButton = app.buttons["Padayon"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5))
        continueButton.tap()

        XCTAssertTrue(app.staticTexts["Mga Alerto"].waitForExistence(timeout: 5),
                      "Alerts list should appear in Waray after onboarding")
    }

    func testSmsDeepLinkOpensStormSurgeAlert() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "war"]
        app.launch()

        XCUIDevice.shared.system.open(URL(string: "handaph://a/7Kq2")!)

        // Custom schemes get a SpringBoard confirmation; Universal Links
        // won't once rdy.ph serves its AASA file.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let openButton = springboard.buttons["Open"]
        if openButton.waitForExistence(timeout: 5) {
            openButton.tap()
        }

        XCTAssertTrue(app.staticTexts["Buhata yana"].waitForExistence(timeout: 10),
                      "Deep link should open the storm-surge alert detail with Waray actions")
        XCTAssertTrue(app.staticTexts["PELIGRO"].firstMatch.exists,
                      "Severity banner should show danger level in Waray")

        // Keep a screenshot of the demo's key screen in the test results.
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "deeplink-alert-detail-waray"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testGlossarySearchFindsStormSurge() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "en"]
        app.launch()

        app.tabBars.buttons["Meanings"].tap()

        let searchField = app.searchFields.firstMatch
        if !searchField.waitForExistence(timeout: 3) {
            app.swipeDown() // reveal the collapsed search bar
        }
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("surge")

        XCTAssertTrue(app.buttons["🌊, Storm surge"].firstMatch.waitForExistence(timeout: 5)
                        || app.staticTexts["Storm surge"].firstMatch.waitForExistence(timeout: 5),
                      "Searching 'surge' should surface the storm surge glossary entry")
    }
}

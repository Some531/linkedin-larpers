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

        // After selecting Waray the whole flow re-renders in Waray.
        let continueButton = app.buttons["Padayon"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5))
        continueButton.tap()

        // Step 2: age band, in Waray, with a back button available.
        XCTAssertTrue(app.staticTexts["Pira an imo edad?"].waitForExistence(timeout: 5),
                      "Age form should show in Waray")
        XCTAssertTrue(app.buttons["Balik"].exists, "Back button should exist on the age form")
        app.buttons["Ubos han 40"].tap()
        app.buttons["Padayon"].tap()

        XCTAssertTrue(app.staticTexts["Mga Alerto"].waitForExistence(timeout: 5),
                      "Alerts list should appear in Waray after onboarding")

        // Relevance radius: the San Jose storm surge (~2 km away) carries a
        // 'near you' chip; the region-wide advisory does not.
        XCTAssertTrue(app.staticTexts["Harani ha imo"].firstMatch.waitForExistence(timeout: 5),
                      "Nearby alert should be chipped 'near you'")
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
        if openButton.waitForExistence(timeout: 12) {
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

    func testMapPersonalisedRiskAndMarkerCard() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "war"]
        app.launch()

        app.tabBars.buttons["Mapa"].tap()

        // Personalised risk banner shows for the active storm-surge alert.
        let banner = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'AN IYO LUGAR'")
        ).firstMatch
        XCTAssertTrue(banner.waitForExistence(timeout: 5), "Personal risk banner should be on the map")

        // Open the household profile and mark an elderly member.
        app.buttons["An Amon Panimalay"].tap()
        let elderlyToggle = app.switches["May edaran (60+) ha balay"].firstMatch
        XCTAssertTrue(elderlyToggle.waitForExistence(timeout: 5))
        setSwitch(elderlyToggle, to: true)
        app.buttons["Padayon"].tap()

        // The banner now carries the leave-earlier advice for that household.
        let advice = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'MAS AGA'")
        ).firstMatch
        XCTAssertTrue(advice.waitForExistence(timeout: 5),
                      "Elderly-household advice should appear after profile change")

        // Tap an evacuation-centre marker; the detail card offers directions.
        let marker = app.buttons["Tacloban City Convention Center"].firstMatch
        XCTAssertTrue(marker.waitForExistence(timeout: 5), "Evacuation marker should be on screen")
        marker.tap()
        let routeButton = app.buttons["Direksyon"].firstMatch
        XCTAssertTrue(routeButton.waitForExistence(timeout: 5),
                      "Marker card should offer walking directions")

        // In-app route: bar appears with an end button (route or fallback).
        routeButton.tap()
        let endRoute = app.buttons["Tapuson an ruta"].firstMatch
        XCTAssertTrue(endRoute.waitForExistence(timeout: 10), "Route bar should appear")
        endRoute.tap()

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "map-personalised-risk-waray"
        attachment.lifetime = .keepAlways
        add(attachment)

        // Reset the toggle so the test is repeatable on the same simulator.
        app.buttons["An Amon Panimalay"].tap()
        if elderlyToggle.waitForExistence(timeout: 3) { setSwitch(elderlyToggle, to: false) }
        app.buttons["Padayon"].tap()
    }

    /// Taps a SwiftUI Toggle until its value matches, retrying once with a
    /// coordinate tap on the switch knob — plain .tap() can land during the
    /// sheet presentation animation and miss.
    private func setSwitch(_ element: XCUIElement, to on: Bool) {
        let want = on ? "1" : "0"
        for attempt in 0..<3 where (element.value as? String) != want {
            if attempt == 0 {
                element.tap()
            } else {
                element.coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap()
            }
            _ = XCTWaiter.wait(for: [XCTestExpectation(description: "settle")], timeout: 0.6)
        }
        XCTAssertEqual(element.value as? String, want, "Switch should be \(on ? "on" : "off")")
    }

    func testAssistantAnswersFromVerifiedCorpusOffline() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "en", "-forceOfflineAssistant", "1"]
        app.launch()

        app.buttons["AI Assistant"].tap()

        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("what is a storm surge")
        app.buttons["Send"].tap()

        // No API key in CI/local test runs -> deterministic offline path,
        // answering with the verified glossary entry.
        let answer = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Sea water pushed onto the land'")
        ).firstMatch
        XCTAssertTrue(answer.waitForExistence(timeout: 8),
                      "Assistant should answer from the verified glossary offline")
        // Learn-more card links the answer to the verified glossary entry.
        XCTAssertTrue(app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Storm surge'")
        ).firstMatch.exists, "Answer should carry a learn-more glossary card")

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "gabay-assistant-offline"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testGlossarySearchFindsStormSurge() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "en"]
        app.launch()

        app.tabBars.buttons["Meanings"].tap()
        XCTAssertTrue(app.navigationBars["Meanings"].waitForExistence(timeout: 5))

        let searchField = app.searchFields.firstMatch
        // The search bar starts collapsed; swipe down until it is hittable.
        for _ in 0..<3 where !(searchField.exists && searchField.isHittable) {
            app.swipeDown()
            _ = searchField.waitForExistence(timeout: 2)
        }
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("surge")

        XCTAssertTrue(app.buttons["🌊, Storm surge"].firstMatch.waitForExistence(timeout: 5)
                        || app.staticTexts["Storm surge"].firstMatch.waitForExistence(timeout: 5),
                      "Searching 'surge' should surface the storm surge glossary entry")
    }
}

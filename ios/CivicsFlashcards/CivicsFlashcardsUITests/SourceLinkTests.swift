import XCTest

final class SourceLinkTests: XCTestCase {
    func testOfficialsLinkOpensSafari() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiCard", "30", "-uiFlipped"]
        app.launch()
        Thread.sleep(forTimeInterval: 3)

        let link = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", "Check current answer at uscis.gov"))
            .firstMatch
        XCTAssertTrue(link.waitForExistence(timeout: 8), "officials link not found on card 30")
        link.tap()
        Thread.sleep(forTimeInterval: 6)

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        XCTAssertTrue(safari.wait(for: .runningForeground, timeout: 15), "Safari did not open")
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "safari-testupdates"; shot.lifetime = .keepAlways
        add(shot)
        // URL bar should show uscis.gov
        let field = safari.textFields.firstMatch
        if field.waitForExistence(timeout: 6) {
            let value = (field.value as? String) ?? ""
            XCTAssertTrue(value.lowercased().contains("uscis.gov"), "Safari URL was: \(value)")
            print("SAFARI_URL_VALUE: \(value)")
        }
    }
}

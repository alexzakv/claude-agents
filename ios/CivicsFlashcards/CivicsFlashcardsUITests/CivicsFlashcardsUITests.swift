import XCTest

/// Drives the app through its core user flow at a watchable pace, so a
/// screen recording of the device shows real usage for App Review.
final class CivicsFlashcardsUITests: XCTestCase {

    private func pause(_ seconds: TimeInterval = 1.6) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func any(_ app: XCUIApplication, label: String) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", label))
            .firstMatch
    }

    func testCoreUserFlow() {
        let app = XCUIApplication()
        app.launch()
        pause(2.5)

        // First launch shows the welcome screen once.
        let start = app.buttons["Start Studying"].firstMatch
        if start.waitForExistence(timeout: 5) {
            start.tap()
            pause(1.5)
        }

        // Home screen: enter the full deck.
        let studyAll = any(app, label: "Study All Questions")
        XCTAssertTrue(studyAll.waitForExistence(timeout: 5))
        studyAll.tap()
        pause(1.8)

        // Card region (below the progress bar, above the buttons).
        let card = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45))

        // Flip to reveal the answer, then back.
        card.tap(); pause(2.2)
        card.tap(); pause(1.2)

        // Swipe to the next two cards.
        for _ in 0..<2 {
            let swipeStart = app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.45))
            let swipeEnd = app.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.45))
            swipeStart.press(forDuration: 0.05, thenDragTo: swipeEnd)
            pause(1.4)
        }

        // Reveal answers with the Flip button, mark the card as known.
        app.buttons["Flip"].firstMatch.tap(); pause(2.0)
        app.buttons["I know this"].firstMatch.tap(); pause(1.4)
        app.buttons["Next"].firstMatch.tap(); pause(1.2)
        app.buttons["Review again"].firstMatch.tap(); pause(1.2)
        app.buttons["Previous"].firstMatch.tap(); pause(1.2)

        // Shuffle via the dedicated toolbar button.
        let shuffle = app.buttons["Shuffle"].firstMatch
        XCTAssertTrue(shuffle.waitForExistence(timeout: 3))
        shuffle.tap(); pause(1.6)

        // Filter menu.
        app.buttons["Filters and options"].firstMatch.tap(); pause(1.8)
        let hideKnown = any(app, label: "Hide known")
        if hideKnown.waitForExistence(timeout: 3) { hideKnown.tap() }
        pause(1.4)

        // Back to home, then About: sources, disclaimer, official link.
        app.navigationBars.buttons.element(boundBy: 0).tap(); pause(1.5)
        app.buttons["About and sources"].firstMatch.tap(); pause(2.0)
        app.swipeUp(); pause(1.4)
        app.swipeDown(); pause(1.0)
        let source = any(app, label: "Official USCIS questions & answers (PDF)")
        if source.waitForExistence(timeout: 3) {
            source.tap()
            pause(4.0)              // Safari shows the official document
            app.activate(); pause(1.8)
        }
        let done = app.buttons["Done"].firstMatch
        if done.waitForExistence(timeout: 3) { done.tap() }
        pause(1.2)

        // End on the home screen.
        XCTAssertTrue(any(app, label: "Study All Questions").waitForExistence(timeout: 4))
    }
}

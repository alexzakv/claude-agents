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

        // Card region (below the progress bar, above the buttons).
        let card = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.42))

        // Flip to reveal the answer, then back.
        card.tap(); pause(2.2)
        card.tap(); pause(1.2)

        // Swipe to the next two cards.
        for _ in 0..<2 {
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.42))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.42))
            start.press(forDuration: 0.05, thenDragTo: end)
            pause(1.4)
        }

        // Reveal answers with the Flip button, mark the card as known.
        app.buttons["Flip"].firstMatch.tap(); pause(2.0)
        app.buttons["I know this"].firstMatch.tap(); pause(1.4)
        app.buttons["Next"].firstMatch.tap(); pause(1.2)
        app.buttons["Review again"].firstMatch.tap(); pause(1.2)
        app.buttons["Back"].firstMatch.tap(); pause(1.2)

        // Open the filter menu and shuffle.
        app.buttons["Filters and options"].firstMatch.tap(); pause(2.0)
        let shuffle = any(app, label: "Shuffle")
        if shuffle.waitForExistence(timeout: 3) { shuffle.tap() }
        pause(1.6)

        // About screen: sources, disclaimer, then a link to the official source.
        app.buttons["About and sources"].firstMatch.tap(); pause(2.2)
        app.swipeUp(); pause(1.6)
        app.swipeDown(); pause(1.2)
        let source = any(app, label: "Official USCIS questions & answers (PDF)")
        if source.waitForExistence(timeout: 3) {
            source.tap()
            pause(4.5)              // Safari shows the official document
            app.activate(); pause(1.8)
        }
        let done = app.buttons["Done"].firstMatch
        if done.waitForExistence(timeout: 3) { done.tap() }
        pause(1.5)

        // One more flip to end on an answer card.
        card.tap(); pause(2.0)
        XCTAssertTrue(app.buttons["Flip"].firstMatch.exists)
    }
}

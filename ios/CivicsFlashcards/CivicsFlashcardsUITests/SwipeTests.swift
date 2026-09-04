import XCTest

final class SwipeTests: XCTestCase {
    /// Regression: swiping must change cards from BOTH the question and answer sides.
    /// The answer side hosts a ScrollView, which previously swallowed the drag.
    func testSwipeWorksOnAnswerSide() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiCard", "1"]
        app.launch()
        Thread.sleep(forTimeInterval: 3)

        func positionLabel() -> String {
            app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Card '")).firstMatch.label
        }
        func swipeLeft() {
            let a = app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.45))
            let b = app.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.45))
            a.press(forDuration: 0.05, thenDragTo: b)
            Thread.sleep(forTimeInterval: 1.5)
        }

        let start = positionLabel()
        XCTAssertEqual(start, "Card 1 of 128")

        // 1) swipe from the QUESTION side
        swipeLeft()
        let afterQuestionSwipe = positionLabel()
        XCTAssertNotEqual(afterQuestionSwipe, start, "swipe failed on the question side")

        // 2) flip to the ANSWER side, then swipe
        app.buttons["Flip"].firstMatch.tap()
        Thread.sleep(forTimeInterval: 2)
        swipeLeft()
        let afterAnswerSwipe = positionLabel()
        XCTAssertNotEqual(afterAnswerSwipe, afterQuestionSwipe, "swipe failed on the ANSWER side")
        print("POSITIONS: \(start) -> \(afterQuestionSwipe) -> \(afterAnswerSwipe)")
    }
}

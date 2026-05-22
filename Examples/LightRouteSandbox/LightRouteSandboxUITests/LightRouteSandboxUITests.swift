import XCTest

final class LightRouteSandboxUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testLaunchStartsOnRoot() {
        launch()

        assertTitle("List")
    }

    func testPushDetailAndPop() {
        launch()

        activate(app.buttons["demo.root.pushDetailButton"])
        assertTitle("Detail 1")

        activate(app.buttons["demo.detail.popButton"], tvOSDownPresses: 3)
        assertTitle("List")
    }

    func testPushEditAndPopToRoot() {
        launch()

        activate(app.buttons["demo.root.pushDetailButton"])
        activate(app.buttons["demo.detail.pushEditButton"])
        assertTitle("Edit 1")

        activate(app.buttons["demo.edit.popToRootButton"], tvOSDownPresses: 1)
        assertTitle("List")
    }

    func testSheetPresentationAndDismissal() {
        launch()

        activate(app.buttons["demo.root.presentSheetButton"], tvOSDownPresses: 2)
        assertTitle("Sheet 1")

        activate(app.buttons["demo.sheet.dismissButton"])
        assertTitle("List")
    }

    func testFullScreenPresentationAndDismissal() {
        launch()

        activate(app.buttons["demo.root.presentFullScreenButton"], tvOSDownPresses: 3)
        assertTitle("Full Screen 1")

        activate(app.buttons["demo.fullScreen.dismissButton"])
        assertTitle("List")
    }

    func testReplaceStackPushesDetailTwoAndCanPopToRoot() {
        launch()

        activate(app.buttons["demo.root.replaceStackButton"], tvOSDownPresses: 4)
        assertTitle("Detail 2")

        activate(app.buttons["demo.detail.popButton"], tvOSDownPresses: 3)
        assertTitle("List")
    }

    func testLaunchArgumentCanStartOnSheet() {
        launch(arguments: ["-demoRoute", "sheet:4"], expectRoot: false)

        assertTitle("Sheet 4")
    }

    func testLaunchArgumentCanStartOnFullScreen() {
        launch(arguments: ["-demoRoute", "fullScreen:5"], expectRoot: false)

        assertTitle("Full Screen 5")
    }

    private func launch(arguments: [String] = [], expectRoot: Bool = true) {
        app.launchArguments = arguments
        app.launch()
        if expectRoot {
            assertTitle("List")
        }
    }

    private func assertTitle(_ text: String) {
        let title = app.staticTexts[text]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "Missing title \(text)")
    }

    private func activate(_ element: XCUIElement, tvOSDownPresses: Int = 0) {
        #if os(tvOS)
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing control \(element)")
        for _ in 0..<tvOSDownPresses {
            XCUIRemote.shared.press(.down)
        }
        XCTAssertTrue(waitForFocus(element), "Expected focus on \(element)")
        XCUIRemote.shared.press(.select)
        #else
        element.tap()
        #endif
    }

    #if os(tvOS)
    private func waitForFocus(_ element: XCUIElement) -> Bool {
        let deadline = Date().addingTimeInterval(3)
        while Date() < deadline {
            if element.hasFocus {
                return true
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))
        }
        return element.hasFocus
    }
    #endif
}
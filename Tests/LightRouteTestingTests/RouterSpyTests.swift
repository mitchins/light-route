import LightRoute
import LightRouteTesting
import XCTest

private enum SpyRoute: Hashable {
    case list
    case detail(Int)
}

final class RouterSpyTests: XCTestCase {
    @MainActor
    func testRouterSpyRecordsPresentations() {
        let spy = RouterSpy<SpyRoute>()

        spy.go(.push(.list))

        XCTAssertEqual(spy.presentations, [.push(.list)])
    }

    @MainActor
    func testRouterSpyPreservesOrder() {
        let spy = RouterSpy<SpyRoute>()

        spy.go(.push(.list))
        spy.go(.sheet(.detail(1)))
        spy.go(.dismiss)

        XCTAssertEqual(spy.presentations, [.push(.list), .sheet(.detail(1)), .dismiss])
    }

    @MainActor
    func testRouterSpyResetClearsPresentations() {
        let spy = RouterSpy<SpyRoute>()
        spy.go(.push(.list))
        spy.go(.fullScreen(.detail(2)))

        spy.reset()

        XCTAssertEqual(spy.presentations, [])
    }
}
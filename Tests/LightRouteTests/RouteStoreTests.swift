import Foundation
import LightRoute
import XCTest

private enum TestRoute: Hashable, Codable {
    case home
    case detail(Int)
    case edit(Int)
}

private struct NonCodableToken: Hashable {}

private struct NonCodableRoute: Hashable {
    let id: Int
    let token: NonCodableToken
}

final class RouteStoreTests: XCTestCase {
    @MainActor
    func testInitialStateDefaultsToEmptyPathAndNilModals() {
        let store = RouteStore<TestRoute>()

        XCTAssertEqual(store.path, [])
        XCTAssertNil(store.sheet)
        XCTAssertNil(store.fullScreen)
    }

    @MainActor
    func testInitialStatePreservesProvidedValues() {
        let store = RouteStore(
            path: [TestRoute.home, .detail(1)],
            sheet: .edit(2),
            fullScreen: .detail(3)
        )

        XCTAssertEqual(store.path, [.home, .detail(1)])
        XCTAssertEqual(store.sheet, .edit(2))
        XCTAssertEqual(store.fullScreen, .detail(3))
    }

    @MainActor
    func testPushAppendsRoute() {
        let store = RouteStore<TestRoute>()

        store.go(.push(.home))

        XCTAssertEqual(store.path, [.home])
    }

    @MainActor
    func testMultiplePushesPreserveOrder() {
        let store = RouteStore<TestRoute>()

        store.go(.push(.home))
        store.go(.push(.detail(1)))
        store.go(.push(.edit(2)))

        XCTAssertEqual(store.path, [.home, .detail(1), .edit(2)])
    }

    @MainActor
    func testPopRemovesLastRoute() {
        let store = RouteStore(path: [TestRoute.home, .detail(1)])

        store.go(.pop)

        XCTAssertEqual(store.path, [.home])
    }

    @MainActor
    func testPopOnEmptyPathIsSafe() {
        let store = RouteStore<TestRoute>()

        store.go(.pop)

        XCTAssertEqual(store.path, [])
    }

    @MainActor
    func testPopDoesNotClearModals() {
        let store = RouteStore(
            path: [TestRoute.home, .detail(1)],
            sheet: .edit(2),
            fullScreen: .detail(3)
        )

        store.go(.pop)

        XCTAssertEqual(store.path, [.home])
        XCTAssertEqual(store.sheet, .edit(2))
        XCTAssertEqual(store.fullScreen, .detail(3))
    }

    @MainActor
    func testPopToRootClearsPath() {
        let store = RouteStore(path: [TestRoute.home, .detail(1), .edit(2)])

        store.go(.popToRoot)

        XCTAssertEqual(store.path, [])
    }

    @MainActor
    func testPopToRootDoesNotClearModals() {
        let store = RouteStore(
            path: [TestRoute.home, .detail(1)],
            sheet: .edit(2),
            fullScreen: .detail(3)
        )

        store.go(.popToRoot)

        XCTAssertEqual(store.path, [])
        XCTAssertEqual(store.sheet, .edit(2))
        XCTAssertEqual(store.fullScreen, .detail(3))
    }

    @MainActor
    func testSheetSetsSheetRoute() {
        let store = RouteStore<TestRoute>()

        store.go(.sheet(.edit(2)))

        XCTAssertEqual(store.sheet, .edit(2))
        XCTAssertNil(store.fullScreen)
    }

    @MainActor
    func testSheetClearsExistingFullScreenRoute() {
        let store = RouteStore<TestRoute>(fullScreen: .detail(3))

        store.go(.sheet(.edit(2)))

        XCTAssertEqual(store.sheet, .edit(2))
        XCTAssertNil(store.fullScreen)
    }

    @MainActor
    func testFullScreenSetsFullScreenRoute() {
        let store = RouteStore<TestRoute>()

        store.go(.fullScreen(.detail(3)))

        XCTAssertEqual(store.fullScreen, .detail(3))
        XCTAssertNil(store.sheet)
    }

    @MainActor
    func testFullScreenClearsExistingSheetRoute() {
        let store = RouteStore<TestRoute>(sheet: .edit(2))

        store.go(.fullScreen(.detail(3)))

        XCTAssertEqual(store.fullScreen, .detail(3))
        XCTAssertNil(store.sheet)
    }

    @MainActor
    func testDismissClearsSheetAndFullScreen() {
        let store = RouteStore(
            path: [TestRoute.home],
            sheet: .edit(2),
            fullScreen: .detail(3)
        )

        store.go(.dismiss)

        XCTAssertNil(store.sheet)
        XCTAssertNil(store.fullScreen)
    }

    @MainActor
    func testDismissDoesNotMutatePath() {
        let store = RouteStore(
            path: [TestRoute.home, .detail(1)],
            sheet: .edit(2),
            fullScreen: .detail(3)
        )

        store.go(.dismiss)

        XCTAssertEqual(store.path, [.home, .detail(1)])
    }

    @MainActor
    func testReplaceStackOverwritesPath() {
        let store = RouteStore(path: [TestRoute.home, .detail(1)])

        store.go(.replaceStack([.edit(2)]))

        XCTAssertEqual(store.path, [.edit(2)])
    }

    @MainActor
    func testReplaceStackDoesNotClearModals() {
        let store = RouteStore(
            path: [TestRoute.home],
            sheet: .edit(2),
            fullScreen: .detail(3)
        )

        store.go(.replaceStack([.detail(4)]))

        XCTAssertEqual(store.path, [.detail(4)])
        XCTAssertEqual(store.sheet, .edit(2))
        XCTAssertEqual(store.fullScreen, .detail(3))
    }
}

final class PresentationTests: XCTestCase {
    func testPresentationIsEquatable() {
        XCTAssertEqual(Presentation<TestRoute>.push(.home), .push(.home))
        XCTAssertNotEqual(Presentation<TestRoute>.push(.home), .push(.detail(1)))
        XCTAssertEqual(Presentation<TestRoute>.replaceStack([.home, .detail(1)]), .replaceStack([.home, .detail(1)]))
    }

    func testConditionalCodableRoundTrips() throws {
        let original = Presentation<TestRoute>.replaceStack([.home, .detail(42), .edit(7)])

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Presentation<TestRoute>.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    @MainActor
    func testRoutesDoNotNeedCodable() {
        let route = NonCodableRoute(id: 1, token: NonCodableToken())
        let store = RouteStore<NonCodableRoute>()

        store.go(.push(route))

        XCTAssertEqual(store.path, [route])
        XCTAssertEqual(Presentation<NonCodableRoute>.push(route), .push(route))
    }
}

private struct TestDeepLinkParser: DeepLinkParser {
    func parse(_ url: URL) -> Presentation<TestRoute>? {
        guard url.scheme == "lightroute" else {
            return nil
        }

        let pathComponents = Array(url.pathComponents.dropFirst())

        if url.host == "home" {
            guard pathComponents.isEmpty else {
                return nil
            }

            return .replaceStack([.home])
        }

        if url.host == "detail",
           pathComponents.count == 1,
           let rawID = pathComponents.first,
           let id = Int(rawID) {
            return .push(.detail(id))
        }

        return nil
    }
}

final class DeepLinkParserTests: XCTestCase {
    func testSampleParserReturnsExpectedPresentation() throws {
        let parser = TestDeepLinkParser()
        let url = try XCTUnwrap(URL(string: "lightroute://detail/42"))

        XCTAssertEqual(parser.parse(url), .push(.detail(42)))
    }

    func testSampleParserReturnsNilForUnrelatedURL() throws {
        let parser = TestDeepLinkParser()
        let url = try XCTUnwrap(URL(string: "https://example.com/detail/42"))

        XCTAssertNil(parser.parse(url))
    }

    func testSampleParserReturnsNilForMalformedURLs() throws {
        let parser = TestDeepLinkParser()
        let urls = try [
            "lightroute://detail",
            "lightroute://detail/not-an-int",
            "lightroute://detail/42/extra",
            "lightroute://unknown/42",
            "lightroute://home/extra"
        ].map { try XCTUnwrap(URL(string: $0)) }

        for url in urls {
            XCTAssertNil(parser.parse(url), "Expected nil for \(url.absoluteString)")
        }
    }
}
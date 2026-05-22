import Foundation
import LightRoute
import XCTest

private enum DocumentationRoute: Hashable {
    case list
    case detail(UUID)
    case create(clientID: UUID?)
}

@MainActor
private final class DocumentationListModel {
    private let router: any Router<DocumentationRoute>

    init(router: any Router<DocumentationRoute>) {
        self.router = router
    }

    func showDetail(id: UUID) {
        router.go(.push(.detail(id)))
    }

    func create(clientID: UUID?) {
        router.go(.sheet(.create(clientID: clientID)))
    }
}

private struct DocumentationDeepLinkParser: DeepLinkParser {
    func parse(_ url: URL) -> Presentation<DocumentationRoute>? {
        guard url.scheme == "myapp" else {
            return nil
        }

        if url.host == "invoices" {
            return .replaceStack([.list])
        }

        if url.host == "invoice",
           let rawID = url.pathComponents.dropFirst().first,
           let id = UUID(uuidString: rawID) {
            return .replaceStack([.list, .detail(id)])
        }

        return nil
    }
}

final class DocumentationSmokeTests: XCTestCase {
    @MainActor
    func testReadmeRouterInjectionShapeCompilesAndRoutes() {
        let store = RouteStore<DocumentationRoute>()
        let model = DocumentationListModel(router: store)
        let id = UUID()

        model.showDetail(id: id)

        XCTAssertEqual(store.path, [.detail(id)])
    }

    @MainActor
    func testReadmeSheetRoutingShapeCompilesAndRoutes() {
        let store = RouteStore<DocumentationRoute>()
        let model = DocumentationListModel(router: store)
        let id = UUID()

        model.create(clientID: id)

        XCTAssertEqual(store.sheet, .create(clientID: id))
    }

    func testReadmeDeepLinkParserShapeCompilesAndParses() throws {
        let parser = DocumentationDeepLinkParser()
        let id = UUID()
        let url = try XCTUnwrap(URL(string: "myapp://invoice/\(id.uuidString)"))

        XCTAssertEqual(parser.parse(url), .replaceStack([.list, .detail(id)]))
    }
}
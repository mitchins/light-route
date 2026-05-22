import Foundation
import LightRoute
import SwiftUI
import XCTest

private enum FlowSmokeRoute: Hashable {
    case list
    case detail(UUID)
    case edit(UUID)
    case create(clientID: UUID?)
    case pdfPreview(UUID)
}

@MainActor
private final class FlowSmokeListModel {
    private let router: any Router<FlowSmokeRoute>

    init(router: any Router<FlowSmokeRoute>) {
        self.router = router
    }

    func showDetail(id: UUID) {
        router.go(.push(.detail(id)))
    }
}

@MainActor
private struct FlowSmokeRootView: View {
    @State private var routeStore = RouteStore<FlowSmokeRoute>()

    var body: some View {
        FlowSmokeNavigation(routeStore: routeStore)
    }
}

@MainActor
private struct FlowSmokeNavigation: View {
    let routeStore: RouteStore<FlowSmokeRoute>

    var body: some View {
        let stack = NavigationStack(path: Binding(
            get: { routeStore.path },
            set: { routeStore.go(.replaceStack($0)) }
        )) {
            FlowSmokeListView(model: FlowSmokeListModel(router: routeStore))
                .navigationDestination(for: FlowSmokeRoute.self) { route in
                    destination(for: route)
                }
        }
        .sheet(isPresented: Binding(
            get: { routeStore.sheet != nil },
            set: { isPresented in
                if !isPresented { routeStore.go(.dismiss) }
            }
        )) {
            if let route = routeStore.sheet {
                sheetDestination(for: route)
            }
        }
        #if os(iOS) || os(tvOS)
        stack.fullScreenCover(isPresented: Binding(
            get: { routeStore.fullScreen != nil },
            set: { isPresented in
                if !isPresented { routeStore.go(.dismiss) }
            }
        )) {
            if let route = routeStore.fullScreen {
                fullScreenDestination(for: route)
            }
        }
        #else
        stack
        #endif
    }

    @ViewBuilder
    private func destination(for route: FlowSmokeRoute) -> some View {
        switch route {
        case .list:
            FlowSmokeListView(model: FlowSmokeListModel(router: routeStore))
        case .detail(let id):
            FlowSmokeDetailView(id: id, model: FlowSmokeDetailModel(router: routeStore))
        case .edit(let id):
            FlowSmokeEditView(id: id)
        case .create(let clientID):
            FlowSmokeCreateView(clientID: clientID)
        case .pdfPreview(let id):
            FlowSmokePDFView(id: id)
        }
    }

    @ViewBuilder
    private func sheetDestination(for route: FlowSmokeRoute) -> some View {
        destination(for: route)
    }

    @ViewBuilder
    private func fullScreenDestination(for route: FlowSmokeRoute) -> some View {
        destination(for: route)
    }
}

@MainActor
private final class FlowSmokeDetailModel {
    init(router: any Router<FlowSmokeRoute>) {}
}

private struct FlowSmokeListView: View {
    let model: FlowSmokeListModel

    var body: some View { EmptyView() }
}

private struct FlowSmokeDetailView: View {
    let id: UUID
    let model: FlowSmokeDetailModel

    var body: some View { EmptyView() }
}

private struct FlowSmokeEditView: View {
    let id: UUID

    var body: some View { EmptyView() }
}

private struct FlowSmokeCreateView: View {
    let clientID: UUID?

    var body: some View { EmptyView() }
}

private struct FlowSmokePDFView: View {
    let id: UUID

    var body: some View { EmptyView() }
}

final class SwiftUIFlowHostSmokeTests: XCTestCase {
    @MainActor
    func testReadmeSwiftUIFlowHostShapeCompiles() {
        _ = FlowSmokeRootView()
    }
}
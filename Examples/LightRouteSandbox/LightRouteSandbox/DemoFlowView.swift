import LightRoute
import SwiftUI

@MainActor
struct DemoFlowView: View {
    let container: DemoContainer

    var body: some View {
        DemoNavigationHost(routeStore: container.routeStore)
    }
}

@MainActor
private struct DemoNavigationHost: View {
    let routeStore: RouteStore<DemoRoute>

    var body: some View {
        NavigationStack(path: Binding(
            get: { routeStore.path },
            set: { routeStore.go(.replaceStack($0)) }
        )) {
            DemoListView(router: routeStore)
                .navigationDestination(for: DemoRoute.self) { route in
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
        .fullScreenCover(isPresented: Binding(
            get: { routeStore.fullScreen != nil },
            set: { isPresented in
                if !isPresented { routeStore.go(.dismiss) }
            }
        )) {
            if let route = routeStore.fullScreen {
                fullScreenDestination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: DemoRoute) -> some View {
        switch route {
        case .list:
            DemoListView(router: routeStore)
        case .detail(let id):
            DemoDetailView(id: id, router: routeStore)
        case .edit(let id):
            DemoEditView(id: id, router: routeStore)
        case .sheet(let id):
            DemoSheetView(id: id, router: routeStore)
        case .fullScreen(let id):
            DemoFullScreenView(id: id, router: routeStore)
        }
    }

    @ViewBuilder
    private func sheetDestination(for route: DemoRoute) -> some View {
        switch route {
        case .sheet(let id):
            DemoSheetView(id: id, router: routeStore)
        default:
            destination(for: route)
        }
    }

    @ViewBuilder
    private func fullScreenDestination(for route: DemoRoute) -> some View {
        switch route {
        case .fullScreen(let id):
            DemoFullScreenView(id: id, router: routeStore)
        default:
            destination(for: route)
        }
    }
}
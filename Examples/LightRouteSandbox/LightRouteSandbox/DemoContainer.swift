import Foundation
import LightRoute

@MainActor
final class DemoContainer {
    let routeStore: RouteStore<DemoRoute>

    init(routeStore: RouteStore<DemoRoute> = RouteStore<DemoRoute>()) {
        self.routeStore = routeStore
    }

    static func fromProcessArguments(_ arguments: [String] = ProcessInfo.processInfo.arguments) -> DemoContainer {
        let container = DemoContainer()
        container.applyLaunchRoute(from: arguments)
        return container
    }

    private func applyLaunchRoute(from arguments: [String]) {
        guard let routeArgumentIndex = arguments.firstIndex(of: "-demoRoute") else {
            return
        }

        let valueIndex = arguments.index(after: routeArgumentIndex)
        guard arguments.indices.contains(valueIndex) else {
            return
        }

        switch Self.route(from: arguments[valueIndex]) {
        case .list:
            routeStore.go(.replaceStack([]))
        case .detail(let id):
            routeStore.go(.replaceStack([.detail(id)]))
        case .edit(let id):
            routeStore.go(.replaceStack([.detail(id), .edit(id)]))
        case .sheet(let id):
            routeStore.go(.sheet(.sheet(id)))
        case .fullScreen(let id):
            routeStore.go(.fullScreen(.fullScreen(id)))
        case nil:
            break
        }
    }

    private static func route(from value: String) -> DemoRoute? {
        let parts = value.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2, let id = Int(parts[1]) else {
            return value == "list" ? .list : nil
        }

        switch parts[0] {
        case "detail":
            return .detail(id)
        case "edit":
            return .edit(id)
        case "sheet":
            return .sheet(id)
        case "fullScreen":
            return .fullScreen(id)
        default:
            return nil
        }
    }
}
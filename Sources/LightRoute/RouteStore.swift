import Foundation
import Observation

@MainActor
@Observable
public final class RouteStore<Route: Hashable>: Router {
    public private(set) var path: [Route]
    public private(set) var sheet: Route?
    public private(set) var fullScreen: Route?

    public init(
        path: [Route] = [],
        sheet: Route? = nil,
        fullScreen: Route? = nil
    ) {
        self.path = path
        self.sheet = sheet
        self.fullScreen = fullScreen
    }

    public func go(_ presentation: Presentation<Route>) {
        switch presentation {
        case .push(let route):
            path.append(route)
        case .sheet (let route):
            sheet = route
            fullScreen = nil
        case .fullScreen(let route):
            fullScreen = route
            sheet = nil
        case .pop:
            _ = path.popLast()
        case .popToRoot:
            path.removeAll()
        case .dismiss:
            sheet = nil
            fullScreen = nil
        case .replaceStack(let routes):
            path = routes
        }
    }
}
import LightRoute

@MainActor
public final class RouterSpy<Route: Hashable>: Router {
    public private(set) var presentations: [Presentation<Route>]

    public init() {
        presentations = []
    }

    public func go(_ presentation: Presentation<Route>) {
        presentations.append(presentation)
    }

    public func reset() {
        presentations.removeAll()
    }
}
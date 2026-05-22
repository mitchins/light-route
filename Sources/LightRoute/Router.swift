@MainActor
public protocol Router<Route>: AnyObject {
    associatedtype Route: Hashable

    func go(_ presentation: Presentation<Route>)
}
import Foundation

public protocol DeepLinkParser<Route> {
    associatedtype Route: Hashable

    func parse(_ url: URL) -> Presentation<Route>?
}
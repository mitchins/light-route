public enum Presentation<Route: Hashable>: Equatable {
    case push(Route)
    case sheet(Route)
    case fullScreen(Route)
    case pop
    case popToRoot
    case dismiss
    case replaceStack([Route])
}

extension Presentation: Codable where Route: Codable {}
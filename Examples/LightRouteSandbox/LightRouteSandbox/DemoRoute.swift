import Foundation

enum DemoRoute: Hashable, Codable {
    case list
    case detail(Int)
    case edit(Int)
    case sheet(Int)
    case fullScreen(Int)
}
# Agent Risk Register

| Risk | Prevention | Review Check |
| --- | --- | --- |
| Agent adds a route registry | Keep route meaning and screen lookup app-owned | Search `Sources` for registry/factory names |
| Agent makes route enums build views | Document routes as pure data | Package sources must not define app routes or import SwiftUI |
| Agent imports UIKit | Core import allowlist is Foundation and Observation | Source scan for `import UIKit` |
| Agent imports AppKit | No platform UI framework in core | Source scan for `import AppKit` |
| Agent imports SwiftUI in core | SwiftUI belongs only in app flow hosts and README examples | Source scan for `import SwiftUI` in `Sources/LightRoute` |
| Agent imports XCTest in production targets | XCTest belongs only in `Tests` | Source scan production sources for `import XCTest` |
| Agent adds a global router singleton | App owns retention explicitly | Search for `static let shared` and `static var shared` |
| Agent adds `AnyView` | Core owns no views | Search for `AnyView` |
| Agent adds macros | No DSL or generated API | Search package sources for macro declarations/usages beyond `@Observable` |
| Agent hides presentation behind opaque magic | Keep `Presentation` as explicit enum cases | Public API review must list only v1 symbols |
| Agent builds DI into package | DI is app-owned | Search for container/service-locator language and types |
| Agent bloats API for hypothetical features | Require a named test or README example for each symbol | Public API review marks unjustified symbols REMOVE |
| Agent writes only happy-path tests | Test plan includes boundaries and negative cases | Verify pop-empty, dismiss/path, replace/modals, deep-link nil, and source scans |
| Agent uses weak router incorrectly in tests | RouterSpy should be strongly owned by tests | Review tests for weak spy ownership |
| Agent makes RouteStore retain child graph | RouteStore stores route values only | Inspect RouteStore stored properties |
| Agent opens RouteStore setters for bindings | Use app-side bindings that call `go` | Verify `public private(set)` on route state |
| Agent requires routes to be Identifiable | Route constraint is only `Hashable` | Inspect generic constraints |
| Agent requires routes to be Codable | Codable is conditional only | Inspect `Presentation` constraints |
| Agent adds a concrete deep-link parser | URL semantics are app-owned | Core should contain protocol only |
| Agent adds RoutePath or RouteBox | Arrays and enum cases are enough for v1 | Reject unless a named test proves need |
| Agent reintroduces legacy support | Modern-only baseline is part of scope | Check Package.swift and docs for Swift 5.9, iOS 17, macOS 14 hedging |
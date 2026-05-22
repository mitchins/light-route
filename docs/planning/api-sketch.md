# API Sketch

These sketches are the implementation contract for v1. They intentionally avoid compatibility fallbacks for older Swift versions.

## Presentation

```swift
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
```

Behavior belongs to `RouteStore`, not to `Presentation`.

## Router

```swift
@MainActor
public protocol Router<Route>: AnyObject {
    associatedtype Route: Hashable
    func go(_ presentation: Presentation<Route>)
}
```

This is the preferred Swift 6 shape. Do not use an older associated-type-only fallback unless the active Swift 6 toolchain rejects this exact form, and document the exact compiler error if that happens.

## RouteStore

```swift
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
    )

    public func go(_ presentation: Presentation<Route>)
}
```

Required semantics:

- `push(route)` appends `route` to `path`.
- `sheet(route)` sets `sheet` and clears `fullScreen`.
- `fullScreen(route)` sets `fullScreen` and clears `sheet`.
- `pop` removes the last path element if present.
- `popToRoot` clears `path`.
- `dismiss` clears `sheet` and `fullScreen`, and does not mutate `path`.
- `replaceStack(routes)` replaces only `path`, and does not clear modal state.

## DeepLinkParser

```swift
import Foundation

public protocol DeepLinkParser<Route> {
    associatedtype Route: Hashable
    func parse(_ url: URL) -> Presentation<Route>?
}
```

The package must not include a concrete parser. Apps own URL semantics.

## RouterSpy

```swift
import LightRoute

@MainActor
public final class RouterSpy<Route: Hashable>: Router {
    public private(set) var presentations: [Presentation<Route>] = []

    public init()

    public func go(_ presentation: Presentation<Route>)

    public func reset()
}
```

`LightRouteTesting` depends on `LightRoute` and not on XCTest.

## Example Route

```swift
enum InvoiceRoute: Hashable, Codable {
    case list
    case detail(UUID)
    case edit(UUID)
    case create(clientID: UUID?)
    case pdfPreview(UUID)
}
```

Routes are app data. They do not build views.

## Intended Flow Host Usage

```swift
import SwiftUI
import LightRoute

struct InvoiceFlowView: View {
    @State private var routeStore = RouteStore<InvoiceRoute>()

    var body: some View {
        NavigationStack(path: Binding(
            get: { routeStore.path },
            set: { routeStore.go(.replaceStack($0)) }
        )) {
            InvoiceListView(router: routeStore)
                .navigationDestination(for: InvoiceRoute.self) { route in
                    switch route {
                    case .list:
                        InvoiceListView(router: routeStore)
                    case .detail(let id):
                        InvoiceDetailView(id: id, router: routeStore)
                    case .edit(let id):
                        InvoiceEditView(id: id, router: routeStore)
                    case .create(let clientID):
                        InvoiceCreateView(clientID: clientID, router: routeStore)
                    case .pdfPreview(let id):
                        InvoicePDFView(id: id)
                    }
                }
        }
        .sheet(item: Binding(
            get: { routeStore.sheet.map(InvoiceSheetRoute.init) },
            set: { _ in routeStore.go(.dismiss) }
        )) { wrappedRoute in
            InvoiceSheetHost(route: wrappedRoute.route, router: routeStore)
        }
    }
}
```

The SwiftUI code above is app-owned. It must never move into `Sources/LightRoute`.
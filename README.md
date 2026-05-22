# LightRoute

## What it is

LightRoute is a tiny route-state package for SwiftUI apps.

It gives you:

- `Presentation<Route>` commands.
- `RouteStore<Route>` route state.
- `Router<Route>` as the small interface for view models.
- `RouterSpy<Route>` for tests.
- `DeepLinkParser<Route>` as a protocol for app-owned URL parsing.

## What it is not

LightRoute is not a navigation framework, coordinator framework, DI container, route registry, transition engine, tab system, alert system, or screen factory.

Routes are app data. They should not build views.

## Install

Add this package with Swift Package Manager and depend on `LightRoute` from the app target.

Use `LightRouteTesting` only from tests.

## Platform support

LightRoute core targets iOS 18, macOS 15, tvOS 18, and watchOS 11 when built with the current Apple toolchain. `LightRoute` and `LightRouteTesting` are compile-verified for a watchOS simulator destination; watchOS support is core route-state support only, not a SwiftUI presentation-demo target.

The runtime sandbox exercises SwiftUI presentation behavior on iOS and tvOS. macOS flow-host shape is covered by package smoke tests, while watchOS remains compile-verified core support.

## Core idea

```swift
viewModel -> any Router<InvoiceRoute> -> RouteStore<InvoiceRoute> -> Flow host renders SwiftUI
```

LightRoute owns route state mechanics. Your app owns route meaning, screen construction, dependency injection, and URL semantics.

## Define routes

```swift
import Foundation

enum InvoiceRoute: Hashable, Codable {
    case list
    case detail(UUID)
    case edit(UUID)
    case create(clientID: UUID?)
    case pdfPreview(UUID)
}
```

Do not put `View` construction on the route enum.

## Own route state

```swift
import LightRoute
import SwiftUI

struct InvoiceFlowView: View {
    @State private var routeStore = RouteStore<InvoiceRoute>()

    var body: some View {
        InvoiceNavigation(routeStore: routeStore)
    }
}
```

Own the store in a flow host or app-owned container. Do not hide it behind a global mutable app object.

## Render with SwiftUI

```swift
import LightRoute
import SwiftUI

struct InvoiceNavigation: View {
    let routeStore: RouteStore<InvoiceRoute>

    var body: some View {
        let stack = NavigationStack(path: Binding(
            get: { routeStore.path },
            set: { routeStore.go(.replaceStack($0)) }
        )) {
            InvoiceListView(model: InvoiceListModel(router: routeStore))
                .navigationDestination(for: InvoiceRoute.self) { route in
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
        #if os(iOS) || os(tvOS)
        stack.fullScreenCover(isPresented: Binding(
            get: { routeStore.fullScreen != nil },
            set: { isPresented in
                if !isPresented { routeStore.go(.dismiss) }
            }
        )) {
            if let route = routeStore.fullScreen {
                fullScreenDestination(for: route)
            }
        }
        #else
        stack
        #endif
    }

    @ViewBuilder
    private func destination(for route: InvoiceRoute) -> some View {
        switch route {
        case .list:
            InvoiceListView(model: InvoiceListModel(router: routeStore))
        case .detail(let id):
            InvoiceDetailView(id: id, model: InvoiceDetailModel(router: routeStore))
        case .edit(let id):
            InvoiceEditView(id: id)
        case .create(let clientID):
            InvoiceCreateView(clientID: clientID)
        case .pdfPreview(let id):
            InvoicePDFView(id: id)
        }
    }

    @ViewBuilder
    private func sheetDestination(for route: InvoiceRoute) -> some View {
        destination(for: route)
    }

    @ViewBuilder
    private func fullScreenDestination(for route: InvoiceRoute) -> some View {
        destination(for: route)
    }
}
```

`fullScreenCover` is iOS/iPadOS/tvOS app code. On macOS, render the same route state with the presentation primitive your app owns.

SwiftUI presentation code belongs in app-owned flow or presentation host files, not in LightRoute core.

## Inject routing into a view model

```swift
import Foundation
import LightRoute

@MainActor
final class InvoiceListModel {
    private let router: any Router<InvoiceRoute>

    init(router: any Router<InvoiceRoute>) {
        self.router = router
    }

    func showInvoice(id: UUID) {
        router.go(.push(.detail(id)))
    }

    func createInvoice(clientID: UUID?) {
        router.go(.sheet(.create(clientID: clientID)))
    }
}
```

View models should talk to `Router`, not SwiftUI presentation APIs.

## Test with RouterSpy

```swift
import LightRoute
import LightRouteTesting
import XCTest

@MainActor
func testShowInvoiceRoutesToDetail() {
    let router = RouterSpy<InvoiceRoute>()
    let model = InvoiceListModel(router: router)
    let id = UUID()

    model.showInvoice(id: id)

    XCTAssertEqual(router.presentations, [.push(.detail(id))])
}
```

## Deep links

```swift
import Foundation
import LightRoute

struct InvoiceDeepLinkParser: DeepLinkParser {
    func parse(_ url: URL) -> Presentation<InvoiceRoute>? {
        guard url.scheme == "myapp" else { return nil }

        if url.host == "invoices" {
            return .replaceStack([.list])
        }

        if url.host == "invoice",
           let rawID = url.pathComponents.dropFirst().first,
           let id = UUID(uuidString: rawID) {
            return .replaceStack([.list, .detail(id)])
        }

        return nil
    }
}
```

LightRoute does not parse your URL scheme for you.

## Sandbox UI harness

The repo includes a small test-only SwiftUI app at [Examples/LightRouteSandbox](Examples/LightRouteSandbox). It exercises `NavigationStack`, `.sheet`, and `.fullScreenCover` against a real `RouteStore` on iOS and tvOS, and includes Xcode UI tests with coverage enabled.

Run it with:

```bash
# Requires xcodegen on PATH. On macOS, for example: brew install xcodegen
cd Examples/LightRouteSandbox
xcodegen generate
cd ../..
xcodebuild test \
    -project Examples/LightRouteSandbox/LightRouteSandbox.xcodeproj \
    -scheme LightRouteSandbox \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6'
```

If that exact simulator runtime is not installed, run `xcodebuild -showdestinations -project Examples/LightRouteSandbox/LightRouteSandbox.xcodeproj -scheme LightRouteSandbox` and choose an available iOS simulator destination.

The sandbox also includes a configured tvOS target and `LightRouteSandbox-tvOS` scheme. tvOS execution is documented in [docs/demo/tvos-sandbox-verification.md](docs/demo/tvos-sandbox-verification.md).

## Architecture rules

Keep these out of ordinary view files and view models. Prefer allowing them only in files named `*FlowView.swift`, `*CoordinatorView.swift`, or `*PresentationHost.swift`:

- `NavigationLink(`
- `.navigationDestination(`
- `.sheet(`
- `.fullScreenCover(`
- `@Environment(\.dismiss)`
- `.presentationDetents(`

Simple grep check:

```bash
violations=$(git grep -nE 'NavigationLink\(|\.navigationDestination\(|\.sheet\(|\.fullScreenCover\(|@Environment\(\\.dismiss\)|\.presentationDetents\(' -- '*.swift' \
  | grep -Ev '(FlowView|CoordinatorView|PresentationHost)\.swift:' || true)

if [ -n "$violations" ]; then
  echo "$violations"
  exit 1
fi
```

Also avoid:

- Route enums building views.
- Injecting `RouteStore` as a global mutable app object.
- View models calling SwiftUI presentation APIs.
- Using LightRoute as a DI container.
- Adding registries or route factories.
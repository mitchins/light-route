# Test Plan

Use XCTest. The repo is modern-only, and there is no existing test framework to preserve.

## RouteStore Behavior

- Initial state defaults to an empty `path`, nil `sheet`, and nil `fullScreen`.
- Initial state initializer preserves provided `path`, `sheet`, and `fullScreen`.
- `push` appends a route to `path`.
- Multiple pushes preserve order.
- `pop` removes the last route.
- `pop` on an empty path is safe.
- `pop` does not clear `sheet` or `fullScreen`.
- `popToRoot` clears `path`.
- `sheet` sets the sheet route.
- `sheet` clears any existing full-screen route.
- `fullScreen` sets the full-screen route.
- `fullScreen` clears any existing sheet route.
- `dismiss` clears both `sheet` and `fullScreen`.
- `dismiss` does not mutate `path`.
- `replaceStack` overwrites `path`.
- `replaceStack` can replace a non-empty stack.
- `replaceStack` does not clear `sheet` or `fullScreen`.

## Presentation

- `Presentation<Route>` is equatable when `Route` is hashable.
- Conditional `Codable` round-trips when `Route: Codable`.
- `Codable` must not be a global route constraint.

## RouterSpy

- `RouterSpy` records presentations.
- `RouterSpy` preserves presentation order.
- `reset()` clears recorded presentations.
- `RouterSpy` is `@MainActor`.
- `LightRouteTesting` production source does not import XCTest.

## Deep Links

- An app-owned parser can return an expected `Presentation<Route>`.
- The same parser returns nil for unrelated URLs.
- Deep-link tests require no UI calls.

## Source Boundary Scans

Scan `Sources/LightRoute` and fail on:

- `import UIKit`
- `import AppKit`
- `import SwiftUI`
- `import XCTest`
- `AnyView`
- `ViewBuilder`
- `NavigationLink`
- `.navigationDestination`
- `.sheet(`
- `.fullScreenCover`
- `static let shared`
- `static var shared`

The SwiftUI modifier scan uses `.sheet(` rather than raw `.sheet` because `.sheet` is also the required enum case spelling inside the core routing API.

Scan all production sources and fail on XCTest imports outside test targets.

## Build Gates

- `swift build` must pass.
- `swift test` must pass.
- If `@Observable` or `Router<Route>` fails under the active Swift 6 toolchain, implementation notes must quote the exact compiler error and describe the smallest compromise.
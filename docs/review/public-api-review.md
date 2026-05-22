# Public API Review

## Core Target: LightRoute

| Symbol | Decision | Reason |
| --- | --- | --- |
| `Presentation<Route: Hashable>` | KEEP | Required command enum for route-state mutations. |
| `Presentation: Equatable` | KEEP | Required for tests, route equality, and spy assertions. |
| `Presentation: Codable where Route: Codable` | KEEP | Conditional only; supports app-owned persistence/deep-link tests without globally constraining routes. |
| `Router<Route>` | KEEP | Tiny command surface for view models and test doubles. |
| `RouteStore<Route: Hashable>` | KEEP | Sole state owner for path, sheet, and full-screen presentation route state. |
| `RouteStore.path` | KEEP | Read-only public state for app-owned flow hosts. Setter remains private. |
| `RouteStore.sheet` | KEEP | Read-only public modal state for app-owned flow hosts. Setter remains private. |
| `RouteStore.fullScreen` | KEEP | Read-only public modal state for app-owned flow hosts. Setter remains private. |
| `RouteStore.go(_:)` | KEEP | Only public mutation entry point. |
| `DeepLinkParser<Route>` | KEEP | Protocol-only hook for app-owned URL parsing. |

## Testing Target: LightRouteTesting

| Symbol | Decision | Reason |
| --- | --- | --- |
| `RouterSpy<Route: Hashable>` | KEEP | Required test double for view models. |
| `RouterSpy.presentations` | KEEP | Read-only assertion surface. Setter remains private. |
| `RouterSpy.go(_:)` | KEEP | Records routed presentations. |
| `RouterSpy.reset()` | KEEP | Supports reuse in focused tests without XCTest dependency. |

## Removed Or Rejected

- No `RoutePath`.
- No `RouteBox`.
- No `LightRouteErrors`.
- No binding helpers.
- No concrete deep-link parser.
- No route registry.
- No DI container.
- No SwiftUI helpers in core.

## Automation

`SourceBoundaryTests.testPublicSourceAPIStaysOnAllowlist` now fails if package source adds public declarations outside the approved source allowlist.
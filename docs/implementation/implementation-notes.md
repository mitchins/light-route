# Implementation Notes

## Toolchain Used

Initial build gate used Apple Swift 6.3.2 from the current Xcode toolchain.

## Observation

`@Observable` worked with `@MainActor` on `RouteStore<Route>` during the initial `swift build` gate. No `ObservableObject` fallback was added.

## Deviations From The Plan

- `Package.swift` declares iOS 18, macOS 15, tvOS 18, and watchOS 11. iPadOS follows the iOS platform declaration in Swift Package Manager.
- watchOS is declared only because `LightRoute` and `LightRouteTesting` compile cleanly for a watchOS simulator without source changes or watchOS-specific APIs.
- The source-boundary scan bans `.sheet(` as the SwiftUI modifier pattern rather than raw `.sheet`, because raw `.sheet` is also the required enum case spelling used by `Presentation` and `RouteStore`.

## Compiler Issues

No compiler issue was observed for the preferred `Router<Route>` primary-associated-type syntax.

No compiler issue was observed for conditional `Codable` conformance on `Presentation`.

No compiler issue was observed for `@Observable` on `RouteStore`.

## Known Limitations

- LightRoute does not provide bindings for SwiftUI. Apps create bindings in flow or presentation host views.
- LightRoute does not parse URLs. Apps implement `DeepLinkParser`.
- LightRoute does not own screens, dependencies, child flows, tabs, alerts, transitions, or presentation styling.
- `sheet` and `fullScreen` presentations keep modal route state exclusive by clearing the other modal slot.
- `dismiss` clears sheet and full-screen route state together by design for v1.

## Explicitly Rejected Non-v1 Features

- Route registries.
- Route-to-view factories.
- Global router singletons.
- DI containers.
- UIKit or AppKit coordinators.
- SwiftUI imports in core.
- `RoutePath`, `RouteBox`, and binding helpers.
- Macro DSLs and property-wrapper DSLs.
- Alert, tab, transition, and child-flow systems.
- Compatibility shims for Swift 5.9, iOS 17, macOS 14, or older platforms.
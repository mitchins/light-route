# Non-Goals

LightRoute exists to stay small. The following are out of scope for v1 and should be treated as review failures if they appear in package source.

- No SwiftUI import in `Sources/LightRoute`.
- No UIKit import.
- No AppKit import.
- No XCTest import in production targets.
- No UIKit or AppKit coordinator abstraction.
- No navigation transition engine.
- No route-to-view registry.
- No destination factory.
- No dependency injection container.
- No global app router or `shared` router.
- No object graph ownership beyond `RouteStore` itself.
- No concrete deep-link URL parser in the package.
- No macro DSL.
- No property-wrapper route declarations.
- No app-level architecture framework.
- No child-flow ownership system.
- No tab system.
- No alert system in v1.
- No `RouteBox`.
- No `RoutePath` wrapper unless tests prove arrays are insufficient.
- No binding helpers in core unless tests prove app-side bindings cannot work.
- No `AnyView` in core.
- No `ViewBuilder` in core.
- No runtime reflection.
- No app-specific route types in `Sources`.
- No compatibility layers for Swift 5.9, iOS 17, macOS 14, or older platform floors.

When tempted to add a helper, ask whether a named test or README example needs it. If not, delete the helper.
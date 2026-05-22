# LightRoute Plan

LightRoute is a deliberately small Swift package for routing state. It owns route state mechanics only. The app owns route meaning, screen construction, dependency injection, and URL semantics.

## Design Goals

- Keep navigation and presentation state out of view models.
- Keep SwiftUI presentation mechanics in app-owned flow or presentation host views.
- Make deep links testable by parsing URLs into route presentations.
- Make routing testable with a tiny spy router.
- Keep compile times low by avoiding builders, macros, registries, reflection, and broad generic hierarchies.
- Make the API boring, explicit, and hard to misuse.

## Non-Goals

- No navigation framework.
- No app architecture framework.
- No UIKit or AppKit coordinator layer.
- No SwiftUI view construction in core.
- No dependency injection container.
- No global router singleton.
- No route registry or route-to-view factory.
- No macro DSL or property-wrapper DSL.
- No transition engine, tab system, alert system, or child-flow ownership system in v1.
- No compatibility shims for older Swift or older Apple platforms.

## Package Structure

Implementation should create only this package shape unless a concrete compiler error or named test proves otherwise:

```text
Package.swift
Sources/
  LightRoute/
    Presentation.swift
    Router.swift
    RouteStore.swift
    DeepLinking.swift
  LightRouteTesting/
    RouterSpy.swift
Tests/
  LightRouteTests/
  LightRouteTestingTests/
README.md
docs/implementation/implementation-notes.md
Examples/
  LightRouteSandbox/       # app-owned SwiftUI sandbox; not part of core
```

Do not add `RoutePath.swift`, `RouteBox.swift`, `LightRouteErrors.swift`, binding helpers, concrete parsers, registries, or factories unless a test or exact Swift 6 compiler issue proves one is necessary.

## Public API List

Core target:

- `Presentation<Route: Hashable>`
- `Router<Route>`
- `RouteStore<Route: Hashable>`
- `DeepLinkParser<Route>`

Testing target:

- `RouterSpy<Route: Hashable>`

No other public symbol belongs in v1 by default.

## Internal And Private Helpers

The planned internal helper list is empty. File-local helpers are acceptable only when they reduce direct repetition without changing the public model or adding indirection.

## Platform Assumptions

- Swift 6 / current Xcode toolchain.
- iOS 18+.
- iPadOS 18+ through the iOS platform declaration.
- macOS 15+.
- tvOS 18+ only if it falls out naturally from the same implementation.
- watchOS only if it requires no special design, branching, or API.

Do not lower platform floors for compatibility.

## Swift And Toolchain Assumptions

- Use Swift Package Manager.
- Prefer the modern primary-associated-type protocol style.
- Use `Observation` and `@Observable` for `RouteStore`.
- Do not add `ObservableObject` fallback unless the current Swift 6 toolchain rejects `@Observable`; document the exact compiler error if that happens.
- Do not design around Swift 5.9-era constrained existential limitations.

## Concurrency Assumptions

- `Router`, `RouteStore`, and `RouterSpy` are `@MainActor`.
- Route state mutation is synchronous and main-actor-only.
- Deep-link parsing is synchronous and UI-free.
- Do not add `Sendable`, `@unchecked Sendable`, detached tasks, or actor hopping unless a concrete implementation problem proves it necessary.

## App-Owned Responsibilities

- Route enum definition and route meaning.
- Screen construction and SwiftUI presentation host code.
- Dependency injection and object graph ownership.
- URL parsing rules and URL semantics.
- Bindings that connect `RouteStore` state to SwiftUI containers.

## What LightRoute Must Never Own

- SwiftUI views or view factories.
- UIKit/AppKit objects.
- Global routing state.
- DI containers or service locators.
- Route registration systems.
- Concrete app routes.
- URL schemes, path grammars, or app-specific deep-link rules.

Example apps under `Examples/` may import SwiftUI and exercise real presentation flows. Those examples must not add API to core or weaken core boundaries.

## Implementation Gate

Before production code is accepted, `swift build` and `swift test` must pass, core must remain free of forbidden imports and patterns, and the public API must remain limited to the listed v1 symbols.
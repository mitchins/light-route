# Review Report

## Scope

Reviewed the implementation against:

- `docs/planning/light-route-plan.md`
- `docs/planning/api-sketch.md`
- `docs/planning/non-goals.md`
- `docs/planning/test-plan.md`
- `docs/planning/agent-risk-register.md`
- `docs/implementation/implementation-notes.md`

## Verdict

PASS after test-hardening rework.

## Findings

### Medium: Boundary Scan Was Too Literal

The initial source-boundary test used direct substring matching. That could miss whitespace variants such as spaced imports, spaced modifiers, or singleton declarations with different spacing.

Resolution: replaced literal checks with regex-based checks in `Tests/LightRouteTests/SourceBoundaryTests.swift`.

### Medium: Public API Was Not Locked

The first test suite verified behavior and forbidden patterns, but it did not fail on newly added public declarations.

Resolution: added a public source API allowlist test covering the approved v1 public surface in `Sources/LightRoute` and `Sources/LightRouteTesting`.

### Low: Pop-To-Root Modal Semantics Were Implicit

`popToRoot` behavior was tested for path clearing, but modal preservation was not explicit.

Resolution: added `testPopToRootDoesNotClearModals` to lock the current path-only semantics.

## Architecture Checks

- Core does not import SwiftUI, UIKit, AppKit, or XCTest.
- Core contains no route registry.
- Core contains no DI container.
- Core contains no route-to-view factory.
- Core contains no global router singleton.
- Core contains no transition engine, tab system, alert system, or child-flow ownership system.
- Core contains no macro or property-wrapper DSL. `@Observable` is the planned Observation macro.
- Package sources contain no app-specific routes or view construction.

## README Check

README remains practical and non-marketing. It shows SwiftUI only as app-owned flow-host code, warns against route-owned views, global mutable routing, DI misuse, SwiftUI presentation APIs in view models, registries, and route factories.

## Verification

- `swift build` passed.
- `swift test` passed with 25 tests.
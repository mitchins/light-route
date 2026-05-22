# Test Coverage Report

## Summary

- `swift test` passed with 33 tests.
- `swift test --enable-code-coverage` passed with 33 tests.
- `xcodebuild test` passed for the iOS sandbox with 8 UI tests.
- `xcodebuild test` passed for the tvOS sandbox with 8 UI tests.
- `xccov` reported iOS sandbox app coverage: 92.82% (375/404).
- `xccov` reported tvOS sandbox app coverage: 92.82% (375/404).
- `LightRoute` and `LightRouteTesting` compile for watchOS simulator.

## RouteStore Coverage

- Initial empty state.
- Initial provided state.
- Push appends route.
- Multiple pushes preserve order.
- Pop removes last route.
- Pop on empty path is safe.
- Pop does not clear modal state.
- Pop-to-root clears path.
- Pop-to-root does not clear modal state.
- Sheet sets sheet route.
- Sheet clears existing full-screen route.
- Full-screen sets full-screen route.
- Full-screen clears existing sheet route.
- Dismiss clears sheet and full-screen route state.
- Dismiss does not mutate path.
- Replace stack overwrites path.
- Replace stack does not clear modal state.

## Presentation Coverage

- Equatable behavior.
- Conditional Codable round-trip with a Codable route.
- Non-Codable route usage with `Presentation` and `RouteStore`.

## RouterSpy Coverage

- Records presentations.
- Preserves order.
- Reset clears presentations.

## Deep-Link Coverage

- App-owned parser returns expected presentation.
- App-owned parser returns nil for unrelated URL.
- App-owned parser returns nil for malformed URLs.

## Boundary Coverage

- Core forbidden imports and patterns.
- Production XCTest import ban.
- Public source API allowlist.

## README Smoke Coverage

- Router injection shape compiles and routes.
- Sheet routing shape compiles and routes.
- Deep-link parser shape compiles and parses.
- SwiftUI flow-host shape compiles on the macOS test host with platform-conditional full-screen handling.

## iOS Sandbox UI Coverage

- Launch starts on root list.
- Push detail and pop back to root.
- Push edit through detail and pop to root.
- Present and dismiss sheet.
- Present and dismiss full-screen cover on iOS simulator.
- Replace stack to detail and pop back.
- Launch arguments can start on sheet.
- Launch arguments can start on full-screen cover.

## tvOS Sandbox UI Coverage

- Launch starts on root list.
- Push detail and pop back to root.
- Push edit through detail and pop to root.
- Present and dismiss sheet.
- Present and dismiss full-screen cover on tvOS simulator.
- Replace stack to detail and pop back.
- Launch arguments can start on sheet.
- Launch arguments can start on full-screen cover.

## watchOS Compile Coverage

- `LightRoute` compiles for `platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.5`.
- `LightRouteTesting` compiles for `platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.5`.
- No watchOS UI presentation behavior is claimed or tested.

## Remaining Non-Blocking Gaps

- watchOS presentation behavior is not executed or claimed.
- macOS presentation behavior is compile smoke-tested, not covered by a sandbox UI app.
- The sandbox is intentionally minimal and does not attempt exhaustive visual testing.
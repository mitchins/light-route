# Release Readiness

## Decision

READY WITH CAVEATS

## Evidence

- `swift build` passed.
- `swift test` passed with 33 tests.
- `swift test --enable-code-coverage` passed with 33 tests.
- `swift package describe` passed.
- `swift package dump-package` passed.
- `xcodebuild build -scheme LightRoute -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.5'` passed.
- `xcodebuild build -scheme LightRouteTesting -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.5'` passed.
- `xcodebuild test` passed for the iOS sandbox on an iPhone 16 Pro iOS 18.6 simulator with 8 UI tests.
- `xcodebuild test` passed for the tvOS sandbox on an Apple TV 4K (3rd generation) tvOS 26.5 simulator with 8 UI tests.
- `xccov` reported iOS sandbox app coverage: 92.82% (375/404).
- `xccov` reported tvOS sandbox app coverage: 92.82% (375/404).
- The sandbox project includes configured iOS and tvOS app and UI test targets.
- Core imports no SwiftUI, UIKit, AppKit, or XCTest.
- Core contains no watchOS-specific APIs or conditional watchOS code.
- Package source contains no app-specific routes or view construction.
- RouterSpy records, preserves order, and resets correctly.
- README examples are smoke-tested for router injection, deep-link parsing, sheet routing, and SwiftUI flow-host compile shape.
- The sandbox exercises real SwiftUI `NavigationStack`, `.sheet`, and `.fullScreenCover` flows with LightRoute state.
- Public API is locked by source allowlist and remains tiny.

## Caveats

- Runtime SwiftUI presentation behavior is covered in the iOS/tvOS sandbox apps, not in package unit tests.
- watchOS support is compile-verified core route-state support only. No watchOS UI presentation behavior is claimed or tested.
- macOS SwiftUI flow-host shape is compile smoke-tested, but there is no macOS sandbox UI test app.

These caveats are non-blocking for a small state-layer package because core owns no SwiftUI runtime presentation behavior.

## Package coverage follow-up

- Final package coverage command: `xcrun llvm-cov report .build/arm64-apple-macosx/debug/LightRoutePackageTests.xctest/Contents/MacOS/LightRoutePackageTests -instr-profile .build/arm64-apple-macosx/debug/codecov/default.profdata Sources/LightRoute/*.swift Sources/LightRouteTesting/*.swift`
- Final package line coverage result: 100.00% total for instrumented production library lines.
- `LightRoute` core reached 100% line coverage for executable lines.
- `LightRouteTesting` reached 100% line coverage for executable lines.
- Remaining caveat: `Presentation.swift`, `Router.swift`, and `DeepLinking.swift` contain declarations only and therefore do not appear in `llvm-cov` line totals because they have no instrumentable executable lines.

## GitHub Actions CI/CD follow-up

- GitHub Actions CI now lives in `.github/workflows/ci.yml` and runs on `macos-15`.
- CI prints the active Swift/Xcode/SDK state before verification.
- CI runs `swift build`, `swift test`, `swift test --enable-code-coverage`, `swift package describe`, and `swift package dump-package` before Sonar.
- CI generates package coverage artifacts before Sonar and feeds Sonar with `.build/reports/sonar-generic-coverage.xml` through `sonar.coverageReportPaths`.
- CI runs the existing iOS sandbox UI tests, tvOS sandbox UI tests, and watchOS package compile verification.
- CI uploads coverage reports, xcresult bundles, destination discovery logs, and watchOS compile logs as artifacts.
- Local Sonar upload is not part of release verification because `SONAR_TOKEN` is provided through GitHub Actions secrets.
# Sandbox Verification Report

## iOS Runtime Verification

Destination used:

```text
platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6
```

Command:

```bash
xcodebuild test \
  -project Examples/LightRouteSandbox/LightRouteSandbox.xcodeproj \
  -scheme LightRouteSandbox \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6' \
  -enableCodeCoverage YES \
  -resultBundlePath .build/LightRouteSandbox-iOS-watchOS-verification-rerun.xcresult
```

Result: passed.

Tests: 8 UI tests.

Covered flows:

- Initial root state.
- Push detail.
- Push edit through detail.
- Pop.
- Pop-to-root.
- Sheet presentation and dismissal.
- Replace stack.
- Full-screen presentation and dismissal.
- Launch into sheet state.
- Launch into full-screen state.

Coverage:

```text
LightRouteSandbox.app  8 source files  92.82% (375/404)
```

## tvOS Runtime Verification

Destination used:

```text
platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=26.5
```

Command:

```bash
xcodebuild test \
  -project Examples/LightRouteSandbox/LightRouteSandbox.xcodeproj \
  -scheme LightRouteSandbox-tvOS \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=26.5' \
  -enableCodeCoverage YES \
  -resultBundlePath .build/LightRouteSandbox-tvOS-watchOS-verification-focus.xcresult
```

Result: passed.

Tests: 8 UI tests.

Coverage:

```text
LightRouteSandbox.app  8 source files  92.82% (375/404)
```

See `docs/demo/tvos-sandbox-verification.md` for destination discovery and the platform-specific UI test input note.

## Package Verification

The core Swift package remains independent of the sandbox and continues to use SwiftPM verification:

```bash
swift build
swift test
swift test --enable-code-coverage
swift package describe
swift package dump-package
```

## watchOS Core Verification

The package targets compile for watchOS simulator without watchOS-specific source code. See `docs/audit/watchos-verification.md`.
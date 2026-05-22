# tvOS Sandbox Verification

## Destination Discovery

Command:

```bash
xcodebuild -project Examples/LightRouteSandbox/LightRouteSandbox.xcodeproj \
  -scheme LightRouteSandbox-tvOS \
  -showdestinations
```

Available simulator destinations included:

```text
{ platform:tvOS Simulator, arch:arm64, id:DA9666CA-28DE-4E76-8AA6-A079922F30A7, OS:26.5, name:Apple TV }
{ platform:tvOS Simulator, arch:arm64, id:6461642C-9A66-4F8B-8A81-90364CAC1241, OS:26.5, name:Apple TV 4K (3rd generation) }
{ platform:tvOS Simulator, arch:arm64, id:55D9F329-0991-4909-AA0B-49918852F900, OS:26.5, name:Apple TV 4K (3rd generation) (at 1080p) }
```

## tvOS Test Command

```bash
xcodebuild test \
  -project Examples/LightRouteSandbox/LightRouteSandbox.xcodeproj \
  -scheme LightRouteSandbox-tvOS \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=26.5' \
  -enableCodeCoverage YES \
  -resultBundlePath .build/LightRouteSandbox-tvOS-watchOS-verification-focus.xcresult
```

Result from `xcresulttool`:

```text
result: Passed
platform: tvOS Simulator
deviceName: Apple TV 4K (3rd generation)
osVersion: 26.5
passedTests: 8
failedTests: 0
skippedTests: 0
totalTestCount: 8
```

Coverage command:

```bash
xcrun xccov view --report --only-targets .build/LightRouteSandbox-tvOS-watchOS-verification-focus.xcresult
```

Coverage result:

```text
ID Name                  # Source Files Coverage
-- --------------------- -------------- ----------------
0  LightRouteSandbox.app 8              92.82% (375/404)
```

## Project Configuration Status

The sandbox project includes:

- `LightRouteSandboxTV` tvOS app target.
- `LightRouteSandboxTVUITests` tvOS UI test target.
- `LightRouteSandbox-tvOS` scheme.
- The same deterministic sandbox app source used by the iOS harness.
- A shared UI test source that uses `XCUIRemote` focus/select activation on tvOS because direct element tap APIs are unavailable there.

## Platform-Specific Presentation Differences

No LightRoute or SwiftUI presentation behavior difference was found in this sandbox run. The only tvOS-specific harness difference is input delivery: the UI tests use remote focus/select on tvOS and direct taps on iOS.

## Caveat Status

The previous runtime blocker is closed on this host. tvOS sandbox UI tests and coverage now pass on `Apple TV 4K (3rd generation),OS=26.5`.

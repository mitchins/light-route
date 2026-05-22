# LightRouteSandbox

This is a deliberately small SwiftUI app for exercising LightRoute in real presentation flows. It is not a sample product.

## What It Covers

- `NavigationStack(path:)` backed by `RouteStore.path`.
- `.sheet` backed by `RouteStore.sheet`.
- `.fullScreenCover` backed by `RouteStore.fullScreen`.
- View-model-style routing through `any Router<DemoRoute>`.
- UI tests that tap real SwiftUI controls and assert visible route state.

## Generate The Project

Requires `xcodegen` on your `PATH`. On macOS, one straightforward option is `brew install xcodegen`.

```bash
cd Examples/LightRouteSandbox
xcodegen generate
```

## Run UI Tests

```bash
xcodebuild test \
  -project Examples/LightRouteSandbox/LightRouteSandbox.xcodeproj \
  -scheme LightRouteSandbox \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6'
```

The scheme has coverage collection enabled for the sandbox app target.

If that exact simulator runtime is not installed, run `xcodebuild -showdestinations -project Examples/LightRouteSandbox/LightRouteSandbox.xcodeproj -scheme LightRouteSandbox` and choose another iOS 18+ simulator destination.

## tvOS

The project also includes a tvOS app target and UI test target:

- `LightRouteSandboxTV`
- `LightRouteSandboxTVUITests`
- `LightRouteSandbox-tvOS`

On a host with a tvOS simulator runtime installed, run:

```bash
xcodebuild test \
  -project Examples/LightRouteSandbox/LightRouteSandbox.xcodeproj \
  -scheme LightRouteSandbox-tvOS \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=26.5' \
  -enableCodeCoverage YES \
  -resultBundlePath .build/LightRouteSandbox-tvOS.xcresult
```

If that exact simulator runtime is not installed, run `xcodebuild -showdestinations -project Examples/LightRouteSandbox/LightRouteSandbox.xcodeproj -scheme LightRouteSandbox-tvOS` and choose another tvOS simulator destination.
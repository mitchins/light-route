# GitHub Actions CI

## Workflow

GitHub Actions CI lives in `.github/workflows/ci.yml` and runs on `macos-15`.

The workflow uses least-privilege GitHub token permissions and pins third-party actions to explicit commit SHAs.

The workflow is the source of truth for:

- Swift package build and test verification.
- SwiftPM coverage generation.
- watchOS compile verification for `LightRoute` and `LightRouteTesting`.
- iOS sandbox UI tests.
- tvOS sandbox UI tests.
- Sonar analysis after coverage exists.

## What the workflow verifies

The package verification steps run:

```bash
swift --version
xcodebuild -version
xcodebuild -showsdks
swift build
swift test
swift test --enable-code-coverage
swift package describe
swift package dump-package
```

After SwiftPM coverage artifacts exist, the workflow generates:

- A human-readable `llvm-cov` text report for CI logs and artifacts.
- An LCOV file as a raw machine-readable coverage artifact.
- A Sonar generic coverage XML file used by Sonar.

Then the workflow runs:

- `xcodebuild build -scheme LightRoute -destination '<watchOS simulator>'`
- `xcodebuild build -scheme LightRouteTesting -destination '<watchOS simulator>'`
- `xcodebuild test` for the iOS sandbox scheme.
- `xcodebuild test` for the tvOS sandbox scheme.
- Sonar scan with `SONAR_TOKEN`.

If `SONAR_TOKEN` is unavailable for the current event context, the workflow prints an explicit skip note instead of failing the verification job for that reason alone.

## Simulator assumptions

The workflow does not hardcode the exact simulator OS version.

Instead it prints `xcodebuild -showdestinations` output and discovers:

- The first available iPhone simulator destination for `LightRouteSandbox`.
- The first available Apple TV simulator destination for `LightRouteSandbox-tvOS`.
- The first available watchOS simulator destination for the Swift package schemes.

This keeps the workflow aligned with the hosted runner’s installed Xcode image rather than a stale local destination string.

## Destination discovery

Discovery is intentionally visible in CI:

- iOS destinations are written to `.build/reports/ios-showdestinations.txt`.
- tvOS destinations are written to `.build/reports/tvos-showdestinations.txt`.
- watchOS destinations are written to `.build/reports/watchos-showdestinations.txt`.

The workflow parses those outputs and exports the chosen destination strings to later steps.

## What fails loudly

The workflow exits with an error instead of silently skipping when:

- SwiftPM coverage artifacts cannot be found.
- No iOS simulator destination is available.
- No tvOS simulator destination is available.
- No watchOS simulator destination is available.
- Coverage files are generated but empty.

That makes runner-image drift obvious in CI logs.

The Sonar step is the exception: it is skipped explicitly when `SONAR_TOKEN` is unavailable, which is expected for some untrusted fork PR contexts.

## Uploaded artifacts

The workflow uploads:

- Package coverage reports under `.build/reports/`.
- LCOV and Sonar generic coverage files.
- iOS sandbox `.xcresult` and summary files.
- tvOS sandbox `.xcresult` and summary files.
- watchOS compile logs.
- toolchain and destination discovery logs.

Those artifacts are intended for CI debugging and are not committed source.
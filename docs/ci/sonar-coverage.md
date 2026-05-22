# Sonar Coverage In CI

## Why coverage must exist before Sonar

Sonar does not generate Swift package coverage on its own. The workflow must run tests with coverage enabled first, then convert the resulting coverage artifacts into a format Sonar can ingest.

If the Sonar step runs before coverage generation, Sonar will analyze source without line coverage input and the coverage view will be incomplete or empty.

## Coverage format used

The workflow generates two machine-readable coverage files:

- `.build/reports/lcov.info`
- `.build/reports/sonar-generic-coverage.xml`

Sonar uses the generic coverage XML file.

Exact Sonar property:

```properties
sonar.coverageReportPaths=.build/reports/sonar-generic-coverage.xml
```

LCOV is still generated and uploaded as an artifact because `llvm-cov` can emit it directly and it is useful for debugging, but the Sonar upload path uses the documented generic coverage property instead of relying on Swift-specific LCOV support assumptions.

## Exact coverage commands

SwiftPM coverage artifact generation:

```bash
swift test --enable-code-coverage
```

Working `llvm-cov` text report command:

```bash
xcrun llvm-cov report \
  .build/arm64-apple-macosx/debug/LightRoutePackageTests.xctest/Contents/MacOS/LightRoutePackageTests \
  -instr-profile .build/arm64-apple-macosx/debug/codecov/default.profdata \
  -ignore-filename-regex='(/\.build/|/Tests/|/Examples/|/docs/)' \
  Sources/LightRoute/*.swift \
  Sources/LightRouteTesting/*.swift
```

LCOV export command:

```bash
xcrun llvm-cov export \
  -format=lcov \
  .build/arm64-apple-macosx/debug/LightRoutePackageTests.xctest/Contents/MacOS/LightRoutePackageTests \
  -instr-profile .build/arm64-apple-macosx/debug/codecov/default.profdata \
  -ignore-filename-regex='(/\.build/|/Tests/|/Examples/|/docs/)' \
  Sources/LightRoute/*.swift \
  Sources/LightRouteTesting/*.swift \
  > .build/reports/lcov.info
```

LCOV-to-Sonar conversion command:

```bash
ruby scripts/ci/lcov_to_sonar_generic.rb \
  .build/reports/lcov.info \
  .build/reports/sonar-generic-coverage.xml
```

## Local reproduction

Run the package verification and coverage steps locally:

```bash
swift build
swift test
swift test --enable-code-coverage
swift package describe
swift package dump-package
```

Discover the actual SwiftPM coverage artifacts if the path differs from the current machine:

```bash
find .build -type f -path '*/codecov/default.profdata'
find .build -type f -path '*/LightRoutePackageTests.xctest/Contents/MacOS/LightRoutePackageTests'
```

Then generate the Sonar input locally:

```bash
mkdir -p .build/reports
xcrun llvm-cov report <test-binary> -instr-profile <profdata> -ignore-filename-regex='(/\.build/|/Tests/|/Examples/|/docs/)' Sources/LightRoute/*.swift Sources/LightRouteTesting/*.swift
xcrun llvm-cov export -format=lcov <test-binary> -instr-profile <profdata> -ignore-filename-regex='(/\.build/|/Tests/|/Examples/|/docs/)' Sources/LightRoute/*.swift Sources/LightRouteTesting/*.swift > .build/reports/lcov.info
ruby scripts/ci/lcov_to_sonar_generic.rb .build/reports/lcov.info .build/reports/sonar-generic-coverage.xml
```

Local Sonar upload is not part of the normal reproduction path because `SONAR_TOKEN` is provided through GitHub Actions secrets. CI is the source of truth for the actual Sonar upload.

If the workflow runs in an event context where `SONAR_TOKEN` is unavailable, CI logs a skip message and still preserves the build/test/coverage verification results.

## Debugging missing coverage in Sonar

If Sonar shows missing or zero coverage:

- Confirm `swift test --enable-code-coverage` ran before the Sonar step.
- Confirm `.build/reports/sonar-generic-coverage.xml` exists and is non-empty.
- Confirm `sonar.coverageReportPaths` points only to `.build/reports/sonar-generic-coverage.xml`.
- Check the uploaded `package-coverage.txt` artifact to verify `llvm-cov` saw the expected production files.
- Check the uploaded `lcov.info` artifact to confirm line data exists before conversion.
- Check the uploaded Sonar XML artifact to confirm paths are repo-relative under `Sources/...`.
- If SwiftPM changes artifact paths on a future runner image, inspect the workflow logs from the artifact discovery step.
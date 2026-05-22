# Package Coverage Report

## Scope

This report covers only the production package library targets under:

- `Sources/LightRoute`
- `Sources/LightRouteTesting`

Excluded from the 100% package target:

- `Examples/`
- sandbox app code
- UI test target code
- docs
- generated/build files

Those surfaces are integration/demo artifacts rather than the package libraries shipped by Swift Package Manager. The package coverage goal applies to the deterministic production library code only.

## Coverage Commands Used

Artifact generation:

```bash
swift test --enable-code-coverage
```

Coverage report command that worked with the active Xcode toolchain:

```bash
xcrun llvm-cov report \
  .build/arm64-apple-macosx/debug/LightRoutePackageTests.xctest/Contents/MacOS/LightRoutePackageTests \
  -instr-profile .build/arm64-apple-macosx/debug/codecov/default.profdata \
  Sources/LightRoute/*.swift \
  Sources/LightRouteTesting/*.swift
```

Line-by-line inspection command:

```bash
xcrun llvm-cov show \
  .build/arm64-apple-macosx/debug/LightRoutePackageTests.xctest/Contents/MacOS/LightRoutePackageTests \
  -instr-profile .build/arm64-apple-macosx/debug/codecov/default.profdata \
  Sources/LightRoute/*.swift \
  Sources/LightRouteTesting/*.swift
```

## Final Coverage Result

`xcrun llvm-cov report` output for production library sources:

```text
Filename                              Regions    Missed Regions     Cover   Functions  Missed Functions  Executed       Lines      Missed Lines     Cover
-----------------------------------------------------------------------------------------------------------------------------------------------------------
LightRoute/RouteStore.swift                11                 0   100.00%          2                 0   100.00%          26                 0   100.00%
LightRouteTesting/RouterSpy.swift          4                 0   100.00%          4                 0   100.00%           8                 0   100.00%
-----------------------------------------------------------------------------------------------------------------------------------------------------------
TOTAL                                      15                 0   100.00%          6                 0   100.00%          34                 0   100.00%
```

Final package line coverage results:

- `Sources/LightRoute`: 100% line coverage for executable lines.
- `Sources/LightRouteTesting`: 100% line coverage for executable lines.

## Uncovered Lines Remaining

None.

`llvm-cov show` reported zero missed executable lines in the production library files that contain instrumentable code.

## Files Not Listed By llvm-cov

These in-scope source files are not listed by `llvm-cov report` because they contain declarations only and no executable lines for line coverage accounting:

- `Sources/LightRoute/Presentation.swift`
- `Sources/LightRoute/Router.swift`
- `Sources/LightRoute/DeepLinking.swift`

This is not hidden uncovered code. `llvm-cov` omits files with no instrumentable executable lines. Their behavior and API shape are still validated by the existing unit and smoke tests, but they do not contribute missed package lines.

## Conclusion

The production package libraries already satisfy the requested line-coverage target on this toolchain. No production API changes, access-control changes, or coverage-only code paths were required.
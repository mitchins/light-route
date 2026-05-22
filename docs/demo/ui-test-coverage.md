# UI Test Coverage

## iOS Sandbox

The iOS sandbox UI harness passed with 8 tests and coverage enabled.

Result bundle:

```text
.build/LightRouteSandbox-iOS-watchOS-verification-rerun.xcresult
```

Coverage command:

```bash
xcrun xccov view --report --only-targets .build/LightRouteSandbox-iOS-watchOS-verification-rerun.xcresult
```

Coverage result:

```text
ID Name                  # Source Files Coverage
-- --------------------- -------------- ----------------
0  LightRouteSandbox.app 8              92.82% (375/404)
```

## tvOS Sandbox

The tvOS sandbox UI harness passed with 8 tests and coverage enabled.

Result bundle:

```text
.build/LightRouteSandbox-tvOS-watchOS-verification-focus.xcresult
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
# Misuse Analysis

## Route Builds Views

Bad:

```swift
enum InvoiceRoute {
    case detail(UUID)

    var body: some View {
        InvoiceDetailView()
    }
}
```

Mitigation:

- README says routes are app data and should not build views.
- Core source scan forbids SwiftUI/view-construction patterns in `Sources/LightRoute`.

## Global Mutable Route Store

Bad:

```swift
extension RouteStore where Route == InvoiceRoute {
    static let shared = RouteStore<InvoiceRoute>()
}
```

Mitigation:

- Source scan rejects `static let shared` and `static var shared` in core.
- README recommends flow-host or app-container ownership.

## View Model Calls SwiftUI Presentation APIs

Bad:

```swift
final class InvoiceModel {
    @Environment(\.dismiss) private var dismiss
}
```

Mitigation:

- README recommends `any Router<Route>` injection.
- Architecture rule grep flags SwiftUI presentation APIs outside presentation host files.

## LightRoute As DI Container

Bad:

```swift
final class RouteRegistry {
    func resolve(_ route: InvoiceRoute) -> Any { ... }
}
```

Mitigation:

- Core has no registry or factory types.
- Source scans reject registry, factory, DI container, and service locator tokens in core.

## Concrete Deep-Link Parser In Package

Bad:

```swift
public struct AppDeepLinkParser: DeepLinkParser { ... }
```

Mitigation:

- Core exposes only `DeepLinkParser<Route>`.
- README and tests keep concrete parsers app-owned.

## Conflicting Modal State

Bad:

```swift
router.go(.sheet(.edit(id)))
router.go(.fullScreen(.pdfPreview(id)))
```

Mitigation:

- `RouteStore` command handling keeps modal slots exclusive: sheet clears full-screen, and full-screen clears sheet.
- Tests lock both transitions.

## Compatibility Drift

Bad:

```swift
// Lower package floors to iOS 17 or add ObservableObject fallback.
```

Mitigation:

- Package declares Swift 6, iOS 18, macOS 15, and tvOS 18.
- Implementation notes explicitly reject Swift 5.9/iOS 17/macOS 14 compatibility shims.
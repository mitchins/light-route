# LightRoute Status

## Done
- 🟢 Core initial step
    Package scaffold and route-state primitives are in place.

## Next
- 🔵 Guard the small-core contract
    Keep route meaning, screen construction, and URL semantics app-owned; add examples and tests that make the boundary explicit.
- 🔵 Add first-class app-owned adapter examples
    Show how SwiftUI flow hosts own `NavigationStack`, `.sheet`, and `.fullScreenCover` without pushing those concerns into core.

## Backlog
- 🔵 Split-view workspace routing support
    NavigationSplitView apps often route through workspace state rather than a push stack.
    
    Explore a first-class split/workspace route model with:
    - section route
    - selection route
    - detail route
    - presentation route
    - missing or deleted entity normalization
    - route restoration
    - deep-link to selected entity
    - testable route reducer
    - SwiftUI `NavigationSplitView` adapter
    
    Acceptance: a macOS/iPad split-view app can open a section, select an entity, present a modal, restore route, and handle a missing selected entity without pretending the whole app is a stack.

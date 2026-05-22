import SwiftUI

@main
struct LightRouteSandboxApp: App {
    @State private var container: DemoContainer

    init() {
        _container = State(initialValue: DemoContainer.fromProcessArguments())
    }

    var body: some Scene {
        WindowGroup {
            DemoFlowView(container: container)
        }
    }
}
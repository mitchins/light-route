import LightRoute
import SwiftUI

@MainActor
struct DemoEditView: View {
    let id: Int
    let router: any Router<DemoRoute>

    var body: some View {
        VStack(spacing: 12) {
            Text("Edit \(id)")
                .font(.title)
                .accessibilityIdentifier("demo.edit.title")

            Button("Pop") {
                router.go(.pop)
            }
            .accessibilityIdentifier("demo.edit.popButton")

            Button("Pop To Root") {
                router.go(.popToRoot)
            }
            .accessibilityIdentifier("demo.edit.popToRootButton")
        }
        .padding()
    }
}
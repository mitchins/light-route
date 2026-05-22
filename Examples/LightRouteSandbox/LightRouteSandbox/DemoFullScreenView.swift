import LightRoute
import SwiftUI

@MainActor
struct DemoFullScreenView: View {
    let id: Int
    let router: any Router<DemoRoute>

    var body: some View {
        VStack(spacing: 12) {
            Text("Full Screen \(id)")
                .font(.title)
                .accessibilityIdentifier("demo.fullScreen.title")

            Button("Dismiss Full Screen") {
                router.go(.dismiss)
            }
            .accessibilityIdentifier("demo.fullScreen.dismissButton")
        }
        .padding()
    }
}
import LightRoute
import SwiftUI

@MainActor
struct DemoDetailView: View {
    let id: Int
    let router: any Router<DemoRoute>

    var body: some View {
        VStack(spacing: 12) {
            Text("Detail \(id)")
                .font(.title)
                .accessibilityIdentifier("demo.detail.title")

            Button("Push Edit \(id)") {
                router.go(.push(.edit(id)))
            }
            .accessibilityIdentifier("demo.detail.pushEditButton")

            Button("Present Sheet \(id)") {
                router.go(.sheet(.sheet(id)))
            }
            .accessibilityIdentifier("demo.detail.presentSheetButton")

            Button("Present Full Screen \(id)") {
                router.go(.fullScreen(.fullScreen(id)))
            }
            .accessibilityIdentifier("demo.detail.presentFullScreenButton")

            Button("Pop") {
                router.go(.pop)
            }
            .accessibilityIdentifier("demo.detail.popButton")
        }
        .padding()
    }
}
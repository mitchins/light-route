import LightRoute
import SwiftUI

@MainActor
struct DemoSheetView: View {
    let id: Int
    let router: any Router<DemoRoute>

    var body: some View {
        VStack(spacing: 12) {
            Text("Sheet \(id)")
                .font(.title)
                .accessibilityIdentifier("demo.sheet.title")

            Button("Dismiss Sheet") {
                router.go(.dismiss)
            }
            .accessibilityIdentifier("demo.sheet.dismissButton")
        }
        .padding()
    }
}
import LightRoute
import SwiftUI

@MainActor
struct DemoListView: View {
    let router: any Router<DemoRoute>

    var body: some View {
        VStack(spacing: 12) {
            Text("List")
                .font(.title)
                .accessibilityIdentifier("demo.root.title")

            Button("Push Detail 1") {
                router.go(.push(.detail(1)))
            }
            .accessibilityIdentifier("demo.root.pushDetailButton")

            Button("Push Edit 1") {
                router.go(.push(.edit(1)))
            }
            .accessibilityIdentifier("demo.root.pushEditButton")

            Button("Present Sheet 1") {
                router.go(.sheet(.sheet(1)))
            }
            .accessibilityIdentifier("demo.root.presentSheetButton")

            Button("Present Full Screen 1") {
                router.go(.fullScreen(.fullScreen(1)))
            }
            .accessibilityIdentifier("demo.root.presentFullScreenButton")

            Button("Replace Stack With Detail 2") {
                router.go(.replaceStack([.list, .detail(2)]))
            }
            .accessibilityIdentifier("demo.root.replaceStackButton")

            Button("Pop To Root") {
                router.go(.popToRoot)
            }
            .accessibilityIdentifier("demo.root.popToRootButton")
        }
        .padding()
    }
}
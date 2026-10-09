// Original examples for the apple-accessibility skill. Type-checked with Swift 6 for iOS 17+.
// Also add `UISupportsAssistiveAccess = YES` to Info.plist (iOS 26+) to opt in.
import SwiftUI

/// Scenes for an app whose deployment target predates iOS 26: declare the
/// Assistive Access scene only where it exists.
@available(iOS 26.0, *)
struct DrawingScenes: Scene {
    var body: some Scene {
        WindowGroup {
            Text("Full drawing app")
        }
        AssistiveAccess {
            NavigationStack {
                AssistiveAccessRootView()
            }
        }
    }
}

@available(iOS 26.0, *)
struct AssistiveAccessRootView: View {
    var body: some View {
        // One or two core tasks, each with an icon and text. The system styles
        // these controls and lays them out as a grid or rows per the person's settings.
        List {
            NavigationLink { ColorChoiceView() } label: { Label("Draw", systemImage: "hand.draw.fill") }
            NavigationLink { Text("Gallery") } label: { Label("Gallery", systemImage: "photo.on.rectangle") }
        }
        .navigationTitle("Drawings")
        .assistiveAccessNavigationIcon(systemImage: "paintbrush.pointed.fill")
    }
}

@available(iOS 26.0, *)
struct ColorChoiceView: View {
    // A single decision per screen, made before the canvas appears.
    let colors: [(name: String, color: Color)] = [("Red", .red), ("Blue", .blue), ("Green", .green)]

    var body: some View {
        List(colors, id: \.name) { item in
            NavigationLink { Text("Canvas") } label: {
                Label(item.name, systemImage: "circle.fill").foregroundStyle(item.color)
            }
        }
        .navigationTitle("Pick a Color")
        .assistiveAccessNavigationIcon(systemImage: "paintpalette.fill")
    }
}

/// Small adjustments inside existing UI when Assistive Access is running (iOS 18+).
@available(iOS 18.0, *)
struct ShareMenuButton: View {
    @Environment(\.accessibilityAssistiveAccessEnabled) private var assistiveAccess

    var body: some View {
        if !assistiveAccess { // Hide a multistep workflow that doesn't fit Assistive Access.
            Button("Export as PDF", systemImage: "square.and.arrow.up") { }
        }
    }
}

#if os(iOS)
/// UIKit-lifecycle apps host the SwiftUI scene from a scene delegate (iOS 26+).
/// `UIHostingSceneDelegate` is a protocol, so the delegate is an NSObject subclass.
@available(iOS 26.0, *)
@MainActor final class AssistiveAccessSceneDelegate: NSObject, UIHostingSceneDelegate {
    nonisolated static var rootScene: some Scene {
        AssistiveAccess { AssistiveAccessRootView() }
    }
}

@available(iOS 26.0, *)
@MainActor func configuration(for session: UISceneSession) -> UISceneConfiguration {
    let configuration = UISceneConfiguration(name: nil, sessionRole: session.role)
    if session.role == .windowAssistiveAccessApplication {
        configuration.delegateClass = AssistiveAccessSceneDelegate.self
    }
    return configuration
}
#endif

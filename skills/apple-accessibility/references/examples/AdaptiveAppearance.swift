// Original examples for the apple-accessibility skill. Type-checked with Swift 6 for iOS 17+.
import SwiftUI

// MARK: Dynamic Type: scaled custom font, scaled metrics, reflow at accessibility sizes.

struct FlightCard: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .title3) private var iconSize = 24.0
    let origin: String, destination: String, minutes: Int

    private var layout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))
    }

    var body: some View {
        layout {
            HStack {
                Text(origin)
                Image(systemName: "airplane")
                    .frame(width: iconSize, height: iconSize)
                    .accessibilityLabel("to")
                Text(destination)
            }
            .font(.custom("AvenirNext-DemiBold", size: 20, relativeTo: .title3))
            Spacer(minLength: 0)
            Text("Arriving in \(minutes) minutes")
                .font(.body)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: Content that can grow scrolls; primary actions stay pinned.

struct BadgeEarnedView: View {
    let message: String

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "rosette")
                    .font(.largeTitle)
                    .accessibilityHidden(true)
                Text("Congratulations!").font(.title.bold())
                    .accessibilityAddTraits(.isHeader)
                Text(message).font(.body) // No line limit: wraps at every size.
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            Button("Close") { }
                .buttonStyle(.borderedProminent)
                .padding()
        }
    }
}

// MARK: Display settings: color, contrast, transparency, borders, motion.

struct StatusBadge: View {
    enum Status { case online, offline }
    let status: Status

    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityShowBorders) private var showBorders // Back-deployed rename of accessibilityShowButtonShapes.
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        HStack(spacing: 6) {
            // Shape and text carry the meaning, so the badge never relies on color alone.
            Image(systemName: status == .online ? "checkmark.circle.fill" : "xmark.octagon.fill")
                .foregroundStyle(status == .online ? Color.green : Color.red)
                .accessibilityHidden(true)
            if differentiateWithoutColor || contrast == .increased {
                Text(status == .online ? "Online" : "Offline").font(.caption.bold())
            }
        }
        .padding(6)
        .overlay {
            if showBorders { Capsule().strokeBorder(.primary) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(status == .online ? "Online" : "Offline")
    }
}

struct FrostedPanel<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding()
            .background {
                if reduceTransparency {
                    RoundedRectangle(cornerRadius: 16).fill(Color(uiColor: .secondarySystemBackground))
                } else {
                    RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                }
            }
    }
}

struct AddToCartButton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var added = false

    var body: some View {
        Button(added ? "Added" : "Add to Cart") {
            // Keep the meaning, change the motion: a fade instead of a bouncing scale.
            withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(duration: 0.4, bounce: 0.5)) {
                added.toggle()
            }
        }
        .scaleEffect(added && !reduceMotion ? 1.1 : 1)
        .sensoryFeedback(.success, trigger: added)
    }
}

struct PromoCarousel: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    let pages: [String]

    var body: some View {
        TabView(selection: $page) {
            ForEach(pages.indices, id: \.self) { index in
                Text(pages[index]).tag(index)
            }
        }
        .task(id: reduceMotion) {
            guard !reduceMotion, !pages.isEmpty else { return } // No auto-advance with Reduce Motion.
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                withAnimation { page = (page + 1) % pages.count }
            }
        }
    }
}

struct AnimatedSticker: View {
    @Environment(\.accessibilityPlayAnimatedImages) private var playAnimatedImages
    @Environment(\.accessibilityDimFlashingLights) private var dimFlashingLights

    var body: some View {
        // Pause looping animation when Animated Images is off; avoid strobing when Dim Flashing Lights is on.
        Image(systemName: "sparkles")
            .symbolEffect(.pulse, isActive: playAnimatedImages && !dimFlashingLights)
            .accessibilityLabel("Celebration sticker")
    }
}

// MARK: iOS 26.4 cross-fade preference for a custom transition.

struct DetailTransition: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if #available(iOS 26.4, *) {
            content.modifier(CrossFadeAwareTransition())
        } else {
            content.transition(reduceMotion ? .opacity : .move(edge: .trailing))
        }
    }
}

@available(iOS 26.4, *)
private struct CrossFadeAwareTransition: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityPrefersCrossFadeTransitions) private var prefersCrossFade

    func body(content: Content) -> some View {
        content.transition(reduceMotion || prefersCrossFade ? .opacity : .move(edge: .trailing))
    }
}

// MARK: Large Content Viewer for a custom bar whose items can't grow.

struct CustomTabBar: View {
    @Binding var selection: Int
    let items: [(title: String, symbol: String)]

    var body: some View {
        HStack {
            ForEach(items.indices, id: \.self) { index in
                Button { selection = index } label: {
                    Image(systemName: items[index].symbol)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel(items[index].title)
                .accessibilityAddTraits(selection == index ? .isSelected : [])
                .accessibilityShowsLargeContentViewer {
                    Label(items[index].title, systemImage: items[index].symbol)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isTabBarIfAvailable)
    }
}

extension AccessibilityTraits {
    /// `.isTabBar` is iOS 18+; fall back to no extra trait on earlier systems.
    static var isTabBarIfAvailable: AccessibilityTraits {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) { return .isTabBar }
        return []
    }
}

#Preview("Accessibility XXXL") {
    FlightCard(origin: "SFO", destination: "HND", minutes: 15)
        .environment(\.dynamicTypeSize, .accessibility5)
}

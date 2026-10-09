// Original examples for the apple-accessibility skill. Type-checked with Swift 6 for iOS 17+.
import SwiftUI

// MARK: Single-axis custom control: one element with value and adjustable action.

struct StarRating: View {
    @Binding var rating: Int
    let maximum = 5

    var body: some View {
        HStack {
            ForEach(1...maximum, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .onTapGesture { rating = index }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) of \(maximum) stars")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: rating = min(maximum, rating + 1)
            case .decrement: rating = max(0, rating - 1)
            @unknown default: break
            }
        }
    }
}

// MARK: Prefer representing a custom control with its system equivalent.

struct BudgetSlider: View {
    @Binding var value: Double
    let label: String

    var body: some View {
        Capsule()
            .fill(.tint.opacity(0.3))
            .frame(height: 44)
            .gesture(DragGesture(minimumDistance: 0).onChanged { _ in /* update value */ })
            .accessibilityRepresentation {
                Slider(value: $value, in: 0...1_000, step: 10) { Text(label) }
                    .accessibilityValue(value.formatted(.currency(code: "USD")))
            }
    }
}

// MARK: Two-dimensional control: named custom actions, not an adjustable trait.

struct EqualizerPad: View {
    @State private var point = CGPoint.zero // Each axis ranges -100...100.

    private func move(dx: CGFloat = 0, dy: CGFloat = 0) {
        point.x = min(100, max(-100, point.x + dx))
        point.y = min(100, max(-100, point.y + dy))
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .frame(width: 240, height: 240)
            .accessibilityElement()
            .accessibilityLabel("Filter")
            .accessibilityValue("Frequency \(Int(point.x)), amplitude \(Int(point.y))")
            // WWDC26 220 shows `.accessibilityActions("Move Up")`, which doesn't exist.
            .accessibilityAction(named: "Move Up") { move(dy: 10) }
            .accessibilityAction(named: "Move Down") { move(dy: -10) }
            .accessibilityAction(named: "Move Left") { move(dx: -10) }
            .accessibilityAction(named: "Move Right") { move(dx: 10) }
    }
}

// MARK: Passthrough-friendly control with throttled announcements.

struct FillLevelControl: View {
    @Binding var level: Double // 0...1
    @State private var lastSpoken: (value: Int, time: Date)?

    var body: some View {
        Rectangle()
            .frame(width: 80, height: 200)
            .accessibilityElement()
            .accessibilityLabel("Coffee amount")
            .accessibilityValue("\(Int(level * 12)) ounces")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: level = min(1, level + 1 / 12)
                case .decrement: level = max(0, level - 1 / 12)
                @unknown default: break
                }
            }
            // A double-tap-and-hold passthrough gesture starts at the current level.
            .accessibilityActivationPoint(UnitPoint(x: 0.5, y: 1 - level))
            .onChange(of: level) { _, newValue in
                let ounces = Int(newValue * 12)
                let now = Date()
                if let last = lastSpoken, last.value == ounces || now.timeIntervalSince(last.time) < 0.3 {
                    return
                }
                lastSpoken = (ounces, now)
                AccessibilityNotification.Announcement("\(ounces) ounces").post()
            }
    }
}

// MARK: Gesture-rich surface: direct touch plus actions for people who can't gesture.

struct PetSurface: View {
    @State private var reaction = "Sleeping"

    var body: some View {
        Circle()
            .gesture(MagnifyGesture().onEnded { _ in reaction = "Hissing" })
            .onTapGesture { reaction = "Meowing" }
            .accessibilityLabel("Virtual cat")
            .accessibilityValue(reaction)
            // The first argument is a Bool; WWDC26 220's `.accessibilityDirectTouch([.requiresActivation])` doesn't compile.
            .accessibilityDirectTouch(options: .requiresActivation)
            .accessibilityAction(named: "Pet") { reaction = "Purring" }
            .accessibilityAction(named: "Tap") { reaction = "Meowing" }
            .accessibilityAction(named: "Pinch") { reaction = "Hissing" }
    }
}

// MARK: Message row: combined element, buttons become actions, conditional overrides.

struct MessageRow: View {
    let sender: String
    let text: String
    let isUnread: Bool
    @State private var isFavorite = false

    var body: some View {
        HStack {
            Circle().fill(.blue).frame(width: 8, height: 8)
                .opacity(isUnread ? 1 : 0)            // Opacity 0 also hides the element.
                .accessibilityLabel("Unread")
            VStack(alignment: .leading) {
                Text(sender).font(.headline)
                Text(text).font(.body)
            }
            Spacer()
            Button { isFavorite.toggle() } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
            }
            .accessibilityLabel(isFavorite ? "Remove from Favorites" : "Add to Favorites")
            Button("Reply", systemImage: "arrowshape.turn.up.left") { }
                .labelStyle(.iconOnly)
        }
        .accessibilityElement(children: .combine)
        .accessibilityInputLabels([Text(sender), Text("Message from \(sender)")])
    }
}

// MARK: Hover-only controls exposed as actions (macOS, iPadOS pointer).

struct TripCard: View {
    @State private var showAttachments = false

    var attachments: some View {
        HStack {
            Button("Location", systemImage: "mappin") { }
            Button("Recording", systemImage: "waveform") { }
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .frame(height: 160)
            .overlay { attachments.opacity(showAttachments ? 1 : 0) }
            .onHover { showAttachments = $0 }
            .accessibilityElement()
            .accessibilityLabel("Weekend at the beach")
            .accessibilityActions { attachments } // Same controls, available without hover.
    }
}

// MARK: Data-rich cell: short label, details on demand.

extension AccessibilityCustomContentKey {
    static var age: Self { Self("Age") }
    static var weight: Self { Self("Weight") }
}

struct DogCell: View {
    let name: String, breed: String, age: String, weight: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(name), \(breed)").font(.headline)
            HStack { Text(age); Text(weight) }.accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        // A string-literal label with a String value is ambiguous in the Xcode 27.1 SDK; use keys or Text.
        .accessibilityCustomContent(.age, age, importance: .high)
        .accessibilityCustomContent(.weight, weight)
    }
}

// MARK: Rotor that compiles for iOS 17-26 deployment targets under the Xcode 27 SDK.

struct Alert: Identifiable { let id: Int; let title: String; let isWarning: Bool }

struct AlertsList: View {
    let alerts: [Alert]

    var body: some View {
        List(alerts) { alert in
            Text(alert.title)
        }
        .accessibilityRotor("Warnings") {
            // Filter first: `if` inside the ForEach requires an iOS 27 deployment target.
            ForEach(alerts.filter(\.isWarning)) { alert in
                AccessibilityRotorEntry(alert.title, id: alert.id)
            }
        }
    }
}

// MARK: Focus a blocking error, but only announce routine status.

struct CheckoutForm: View {
    @State private var errorMessage: String?
    @AccessibilityFocusState private var errorFocused: Bool

    var body: some View {
        Form {
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .accessibilityFocused($errorFocused)
            }
            Button("Pay") { submit() }
        }
        .navigationTitle("Checkout")
    }

    private func submit() {
        errorMessage = "Card number is incomplete."
        errorFocused = true
    }
}

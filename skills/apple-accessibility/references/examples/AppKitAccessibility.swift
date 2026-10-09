// Original examples for the apple-accessibility skill. Type-checked with Swift 6 for macOS 14+.
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: A custom-drawn control that adopts the button role protocol.

final class ColorSwatchButton: NSView, @preconcurrency NSAccessibilityButton {
    var colorName = "Red"
    var action: () -> Void = { }

    override func mouseUp(with event: NSEvent) { action() }

    // NSAccessibilityButton requirements: label and press.
    override func accessibilityLabel() -> String? { colorName }
    override func accessibilityPerformPress() -> Bool { action(); return true }

    // Keyboard users need the same action.
    override var acceptsFirstResponder: Bool { true }
    override func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers == " " { action() } else { super.keyDown(with: event) }
    }
}

// MARK: A view that draws several items exposes them as accessibility children.

final class SeatMapView: NSView {
    struct Seat { let name: String; let rect: NSRect; let isTaken: Bool }
    var seats: [Seat] = [] { didSet { rebuildElements() } }
    private var elements: [NSAccessibilityElement] = []

    private func rebuildElements() {
        elements = seats.map { seat in
            let element = NSAccessibilityElement()
            element.setAccessibilityRole(.button)
            element.setAccessibilityLabel(seat.name)
            element.setAccessibilityValue(seat.isTaken ? "Taken" : "Available")
            element.setAccessibilityParent(self)
            element.setAccessibilityFrameInParentSpace(seat.rect) // Recomputed as the view moves.
            return element
        }
        NSAccessibility.post(element: self, notification: .layoutChanged)
    }

    override func isAccessibilityElement() -> Bool { true }
    override func accessibilityRole() -> NSAccessibility.Role? { .group }
    override func accessibilityLabel() -> String? { "Seat map" }
    override func accessibilityChildren() -> [Any]? { elements }
}

// MARK: Respect display settings that AppKit apps read from NSWorkspace.

@MainActor func prefersReducedMotion() -> Bool {
    NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
}

@MainActor func announce(_ message: String) {
    NSAccessibility.post(element: NSApp as Any, notification: .announcementRequested,
                         userInfo: [.announcement: message, .priority: NSAccessibilityPriorityLevel.high.rawValue])
}
#endif

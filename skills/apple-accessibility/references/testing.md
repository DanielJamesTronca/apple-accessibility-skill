# Testing and verification

Automated checks catch regressions; only assistive technologies show whether a task is possible. Use both, and report which ran.

## 1. Build a task × setting × device matrix

List the main tasks per screen: first launch and onboarding, sign-in and account creation, empty states, the primary features, purchase, and settings. For each device type you ship (iPhone, iPad, Mac, Apple Watch, Apple TV, Vision Pro), test each task with: [Performing accessibility testing for your app](https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app).

- **Visual settings:** Bold Text; Larger Accessibility Sizes (AX1, AX3, AX5); Button Shapes; On/Off Labels; Reduce Transparency; Increase Contrast; Differentiate Without Color; Color Filters; Smart Invert; Reduce Motion; Dim Flashing Lights; light and dark appearance.
- **Media settings:** Closed Captions + SDH; Audio Descriptions; Show Audio Transcriptions.
- **Assistive technologies:** VoiceOver (with Screen Curtain), Voice Control, Switch Control, Full Keyboard Access, Assistive Access, and the platform-specific ones (AssistiveTouch on Watch, Pointer and Dwell Control on visionOS).

Success means a person can complete every task using only that technology, everything is perceivable, and each element reports a correct name and status.

## 2. Learn the minimum gestures

Use the Accessibility Shortcut (triple-click the side or Home button, or triple-press the Digital Crown on Vision Pro) to toggle features quickly. On a Mac, Command-F5 toggles VoiceOver.

| VoiceOver (iOS) | Action |
| --- | --- |
| Touch / drag | Speak the item under your finger |
| Swipe right or left | Next or previous item |
| Double-tap | Activate |
| Two-finger tap | Pause or resume speech |
| Two-finger swipe up | Read all from the top |
| Three-finger swipe | Scroll |
| Two-finger rotate, then swipe up or down | Choose a rotor, then move by it |
| Two-finger scrub (Z) | Escape or back |
| Three-finger triple-tap | Screen Curtain |
| Double-tap and hold | Passthrough gesture |

Voice Control: "Show names", "Show numbers", "Tap …", "Scroll down", "Show commands". Practice areas live in Settings (VoiceOver Practice, the Voice Control guide). Turn on VoiceOver > Verbosity > Speak Hints if you provide hints. Test in a quiet room. [Supporting VoiceOver in your app](https://developer.apple.com/documentation/uikit/supporting-voiceover-in-your-app).

What to check with VoiceOver: every element is reachable by swiping in both directions without skipping or looping; order matches meaning; labels, values, and traits are correct and current; modals trap focus and close with escape; focus doesn't jump to the top after updates; status changes are announced; custom gestures have actions; and charts and images are described or hidden as appropriate.

## 3. Accessibility Inspector

Open it from Xcode > Open Developer Tool > Accessibility Inspector, then choose the Mac app, simulator, or device. [Inspecting the accessibility of the screens in your app](https://developer.apple.com/documentation/accessibility/inspecting-the-accessibility-of-screens).

- **Inspection** (Option-Space): Basic, Actions, Element, and Hierarchy sections. Navigation controls walk elements in VoiceOver order (Control-Command-Arrow) and speak each element. Inspection > Disable Auto-interact Into Elements restricts navigation to siblings.
- **Audit** (per screen): element description, hit region, contrast, element detection (all platforms); clipped text, traits, Dynamic Type (iOS, watchOS, tvOS); parent/child and action (macOS). Each issue has highlighting, a screenshot, and fix suggestions. Export with File > Save Audit Report As (HTML). [Performing accessibility audits for your app](https://developer.apple.com/documentation/accessibility/performing-accessibility-audits-for-your-app).
- **Settings:** toggle Invert Colors, Increase Contrast, Reduce Transparency, Reduce Motion, Full Keyboard Access, Differentiate Without Color, Grayscale, Button Shapes, On/Off Labels, Bold Text, and Dynamic Type on the target. [Testing system accessibility features in your app](https://developer.apple.com/documentation/accessibility/testing-system-accessibility-features-in-your-app).
- **Color Contrast Calculator:** Window > Show Color Contrast Calculator (⌥⌘C).

## 4. Xcode previews and runtime overrides

- SwiftUI Previews: Variants → Dynamic Type Variants (or color scheme and orientation variants). `#Preview(traits: .assistiveAccess)` previews an Assistive Access scene. The canvas Accessibility Preview shows elements, labels, traits, and sort order without running the app. [SwiftUI Accessibility: Beyond the basics](https://developer.apple.com/videos/play/wwdc2021/10119/).
- Debugger Environment Overrides and Xcode 27's simulator inspector toggle text size, contrast, and appearance live. [What's new in Xcode 27](https://developer.apple.com/videos/play/wwdc2026/258/).

## 5. Automated tests

XCUITest finds elements through the accessibility hierarchy, so UI tests already exercise some accessibility. Add explicit checks:

```swift
func testCheckoutAccessibility() throws {
    let app = XCUIApplication()
    app.launch()
    continueAfterFailure = true
    app.buttons["checkout"].tap()   // identifier, not label
    try app.performAccessibilityAudit(for: [.contrast, .dynamicType, .textClipped,
                                            .sufficientElementDescription, .hitRegion]) { issue in
        // Return true only for reviewed false positives.
        issue.auditType == .contrast && issue.element?.identifier == "brandLogo"
    }
}
```

- `performAccessibilityAudit(for:_:)` (iOS 17, macOS 14, tvOS 17, watchOS 10) fails the test on issues without assertions. Audit types: `contrast`, `elementDetection`, `hitRegion`, `sufficientElementDescription`, plus `dynamicType`, `textClipped`, `trait` (iOS/tvOS/watchOS) and `action`, `parentChild` (macOS). The handler returns `true` to ignore an issue. [Perform accessibility audits for your app](https://developer.apple.com/videos/play/wwdc2023/10035/).
- An audit covers only what is on screen. Navigate to each screen and state, or run the audit in `tearDown` with per-test opt-outs, and group audit tests in a test plan.
- UIKit `automationElements` (iOS 17) exposes elements to UI tests without changing what assistive technologies see. When you override it, list every element.
- **VoiceOver automation (iOS, macOS, tvOS, watchOS, visionOS 27):** `XCUIDevice.shared.voiceOverService` provides `enable()`, `disable()`, `isEnabled`, `moveForward()`, `moveBackward()`, `currentSpeech()`, and (iOS/macOS) `moveIn()`/`moveOut()`, returning `Output.utterance` (for example "Add Favorites, button"). Use it to assert spoken order and wording, or as a smoke test that no element is silent. Errors: `failedToStart`, `notRunning`, `noSpeech`, `failedToStop`. Verified in the Xcode 27.1 SDK; Apple's lab indicated it should work in Simulator, and a forum report shows Device Hub's VoiceOver toggle didn't support activation gestures early in the beta. Confirm on your toolchain. [Group Lab, 53:08](https://developer.apple.com/videos/play/wwdc2026/8005/?time=3188), [Forum thread](https://developer.apple.com/forums/thread/850145).

```swift
@MainActor func testHomeSpeechOrder() throws {
    let voiceOver = XCUIDevice.shared.voiceOverService
    try voiceOver.enable()
    defer { try? voiceOver.disable() }
    XCUIApplication().launch()
    XCTAssertEqual(try voiceOver.moveForward().utterance, "Library, heading")
}
```

- Reusable components can require an identifier and a label in their initializers so new screens can't ship unlabeled. [Group Lab, 36:30](https://developer.apple.com/videos/play/wwdc2026/8005/?time=2190).
- Snapshot-test accessibility sizes and increased contrast for layout regressions. Snapshot tests don't verify semantics.

See [AccessibilityUITests.swift](examples/AccessibilityUITests.swift).

## 6. Know the limits

- Apple's testing guide says VoiceOver, Voice Control, Switch Control, and Assistive Access must be tested on a physical device. Xcode 27 adds VoiceOver to the simulator and Device Hub, with the beta limits above. Treat simulator VoiceOver as supplementary.
- Passing audits doesn't mean the app is accessible: audits can't judge label quality, order, task completion, motion comfort, or cognitive load.
- A type-check or compile proves only that APIs exist.
- Real users find what checklists miss. Involve people who use these technologies, and fix issues found late before claiming a label.

## Report format

For each finding: the task blocked, the technology or setting, the element and file/line, the evidence (spoken output, screenshot, audit issue), severity (blocks the task, hinders it, polish), and the smallest fix. List the checks that ran, the checks that need hardware or users, and what remains unverified.

# Input alternatives: voice, switches, keyboard, pointer, and touch accommodations

Many people can't use touch, a mouse, or precise gestures: tremors, paralysis, limb differences, temporary injury, or simply full hands. Apple platforms offer Voice Control, Switch Control, Full Keyboard Access, AssistiveTouch, Dwell Control, Pointer Control, Head and Eye Tracking, Touch Accommodations, and Sound Actions. Each relies on the same accessibility elements as VoiceOver, plus a few input-specific APIs. Two people with the same disability may choose completely different tools. [App accessibility for Switch Control](https://developer.apple.com/videos/play/wwdc2020/10019/), [Support Full Keyboard Access in your iOS app](https://developer.apple.com/videos/play/wwdc2021/10120/).

## Universal rules

- **Everything reachable, everything operable.** If something can be tapped, clicked, dragged, or swiped, it must be a focusable element with an action. Gesture-only, hover-only, and shake-only features need a button, menu item, custom action, or keyboard shortcut.
- **Simple gestures.** Use the simplest gesture for frequent actions; avoid custom multi-finger and multi-hand gestures. [HIG: Accessibility – Mobility](https://developer.apple.com/design/human-interface-guidelines/accessibility).
- **Targets and spacing.** Default/minimum control sizes: iOS and watchOS 44×44/28×28 pt, macOS 28×28/20×20, tvOS 66×66/56×56, visionOS 60×60/28×28. Leave about 12 pt around bezeled controls and about 24 pt around borderless ones. Enlarge hit areas with padding or `contentShape`, not by shrinking visuals.
- **No timeouts.** Switch scanning and voice dictation are slow. Avoid auto-dismissing UI and short pairing or verification code timers—at least when Switch Control is running (`UIAccessibility.isSwitchControlRunning`)—or let people extend them.
- **Forgive errors.** Confirm destructive or high-consequence actions (delete account, pay, sign out). Mis-taps are more likely with switches and tremors.
- **Privacy.** Switch users often have devices mounted on wheelchairs where others can see them. Don't leave sensitive data on screen longer than needed.

## Voice Control

People say "Show names" or "Show numbers", then "Tap Compose", "Tap 4", "Scroll down", "Swipe up with two fingers", "Type hello", "Select hello", "Delete that". Natural-language references improve in iOS 27. [Voice Control evaluation criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/voice-control-evaluation-criteria), [Group Lab](https://developer.apple.com/videos/play/wwdc2026/8005/).

- Every actionable element needs a name, ideally matching its visible text; otherwise people must say "Show names" to discover it. Icon buttons need labels plus synonyms: `accessibilityInputLabels(["Settings", "Preferences", "Gear"])` (UIKit `accessibilityUserInputLabels`). List them in descending order of importance; without input labels, people use the accessibility label.
- Elements with custom actions show a double chevron; people say "Show actions for 4". Hidden-on-hover or swipe-revealed UI needs a speech-only route.
- Panning canvases and maps need "Pan left", "Zoom out" equivalents through standard scroll views or zoom actions.
- Text fields must accept dictation and editing commands; custom text entry needs testing.
- Recording or custom dictation features must start and stop by voice.
- App Intents and Siri make frequent tasks voice-reachable for everyone, including Voice Control users.

## Switch Control

People navigate with one or more switches: external buttons, keyboard keys, game controllers, the screen, the camera (head movements), or sounds. Auto-scanning moves a cursor through groups, then items; selecting opens a menu of actions and gestures.

- Grouping drives efficiency: set `accessibilityNavigationStyle = .combined` on containers that should scan as one group, and order with `accessibilityElements` when geometry misleads (curvy paths, grids).
- Custom actions appear on the **first page** of the Switch Control menu. Give them images (`UIAccessibilityCustomAction(name:image:…)`, iOS 14) or a `Label` in SwiftUI's `accessibilityAction { } label: { }`; otherwise the menu shows the first letter.
- `accessibilityElementDidBecomeFocused()` / `accessibilityElementDidLoseFocus()` let you react to scanning focus, for example by revealing a card's face when manual scanning reaches it (as an opt-in behavior).
- `accessibilityRespondsToUserInteraction`: set `true` on a static label that is tappable so switches stop on it, and `false` on an element that should be spoken by VoiceOver but skipped by motor technologies. Don't override `canBecomeFocused` for this; it changes Tab navigation for everyone.
- Detect the technology only to adapt behavior: `UIAccessibility.isSwitchControlRunning`, `@Environment(\.accessibilitySwitchControlEnabled)`.

## Full Keyboard Access and keyboard support

Full Keyboard Access (iOS/iPadOS 13.4+, visionOS, and the Mac's keyboard navigation) lets people operate everything from a hardware keyboard: Tab and arrow keys move, Space activates, Tab-Z opens actions, Tab-F finds elements by name, and gesture mode handles drags. [Support Full Keyboard Access in your iOS app](https://developer.apple.com/videos/play/wwdc2021/10120/), [Accessibility design for Mac Catalyst](https://developer.apple.com/videos/play/wwdc2020/10117/).

- The focus cursor should land only on interactive elements. Use `accessibilityRespondsToUserInteraction = false` for informational elements.
- Shape the cursor with `accessibilityPath` (UIKit) or `contentShape`; it's shared with VoiceOver.
- Provide keyboard shortcuts for frequent actions: UIKit `UIKeyCommand` in `buildMenu(with:)` with a `discoverabilityTitle` (shown when holding Command), gated by `canPerformAction`; SwiftUI `.keyboardShortcut` and `commands`. They help Full Keyboard Access and keyboard power users alike. Don't override system or accessibility shortcuts.
- Collection and table views: `selectionFollowsFocus` lets arrow keys change the selection; SwiftUI `focusable`, `@FocusState`, and `focusSection` structure focus.
- Mac users expect every function to be keyboard-reachable and accelerators to jump between regions (sidebar, inspector, editor). Test with "Use keyboard navigation to move focus between controls" turned on.
- Games: read raw keys from `UIPress.key?.keyCode` and support remapping.

## AssistiveTouch, Dwell, Pointer Control, and tracking

- iOS AssistiveTouch, Dwell, Head Tracking, and Eye Tracking (iOS 18, built-in camera) drive a pointer. Elements need adequate size and must not depend on multi-touch.
- watchOS AssistiveTouch uses hand gestures (clench to tap, double clench for the action menu, pinch for next, double pinch for previous) or wrist motion. Only interactive elements (buttons, toggles, navigation links, tap-gesture views, views with actions or button/adjustable traits) are focusable. Mark tappable containers with `accessibilityRespondsToUserInteraction(true)`. The cursor frame equals the tappable shape, so enlarge small targets with `contentShape`. Custom actions appear first in the action menu. [Create accessible experiences for watchOS](https://developer.apple.com/videos/play/wwdc2021/10223/).
- `accessibilityQuickAction(style:content:)` (watchOS 9) adds a primary quick action—pause/resume a workout, play/pause music—that people trigger with the AssistiveTouch Quick Actions gesture.
- visionOS: Dwell Control (tap, scroll, long press, drag), Pointer Control (head, wrist, or index finger instead of eyes), and Switch Control's camera position controls. Ensure full functionality with Dwell's gesture set, avoid head-anchored content, and offer alternatives to experiences that require reaching or moving the body. See [platforms](platforms.md).
- `AccessibilitySettings.openSettings(for:)` (iOS 18) can deep-link to accessibility settings sections such as `.assistiveTouch`, `.assistiveTouchDevices`, and `.dwellControl` (26.0) or `.captionStyles` (26.4); check `canOpenSettings(for:)` (26.4) first.

## Guided Access and single-app modes

Guided Access locks the device to one app with optional touch, motion, keyboard, and button restrictions. Kiosks, testing, and medical intake use programmatic modes built on it. [Create accessible Single App Mode experiences](https://developer.apple.com/videos/play/wwdc2022/10152/).

- Add custom restrictions with `UIGuidedAccessRestrictionDelegate` on the app delegate: identifiers, titles, optional details, and `guidedAccessRestriction(withIdentifier:didChange:)`. Query with `UIAccessibility.guidedAccessRestrictionState(forIdentifier:)`. Use them to lock account settings or purchases.
- Autonomous Single App Mode: `UIAccessibility.requestGuidedAccessSession(enabled:completionHandler:)` requires a supervised device with the app allow-listed. Observe `isGuidedAccessEnabled`. Assessment mode uses AutomaticAssessmentConfiguration and an entitlement.
- Kiosks must stay accessible: configure always-on accessibility features or the Accessibility Shortcut in MDM before locking. During a session, `UIAccessibility.configureForGuidedAccess(features:enabled:completionHandler:)` can toggle Zoom, VoiceOver, Invert Colors, AssistiveTouch, or Grayscale, for example to reset between customers.
- Payment-acceptance apps with the `com.apple.developer.accessibility.merchant-api-control` entitlement can use `AXFeatureOverrideSessionManager` (iOS 18.2) to temporarily enable or disable VoiceOver, Voice Control, Zoom, Invert Colors, or Grayscale; ending all sessions restores the person's state. Don't use it outside that entitlement's purpose.

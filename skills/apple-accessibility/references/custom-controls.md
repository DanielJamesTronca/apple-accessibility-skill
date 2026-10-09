# Custom controls and gestures

A sighted person infers a control's **purpose, value, available actions, and feedback** from its appearance. Expose each of those to assistive technologies. VoiceOver describes a system slider as "Brightness, 50%, adjustable. Swipe up or down with one finger to adjust the value" and speaks each new value. A custom control should behave the same way. [Refine accessibility for custom controls](https://developer.apple.com/videos/play/wwdc2026/220/).

## Choose the mechanism

| Control shape | Mechanism | Notes |
| --- | --- | --- |
| Behaves like a system control | `accessibilityRepresentation { Slider/Toggle/Button… }` | Replaces the element with the system control's label, value, traits, and actions; macOS speaks the role. Best default. |
| One value along one axis (rating, volume, stepper, carousel) | `.accessibilityElement()` + label + value + `.accessibilityAdjustableAction` | UIKit: `.adjustable` trait + `accessibilityIncrement()`/`accessibilityDecrement()`. Clamp values. |
| Several discrete operations or two axes | Custom actions: `.accessibilityAction(named:)` | VoiceOver actions rotor, Switch Control's top menu, Voice Control ("Show actions for 4"), Full Keyboard Access (Tab-Z). |
| Fine-grained continuous adjustment | Passthrough (double-tap and hold) starting at `accessibilityActivationPoint` | Set the activation point to the current value's position; announce throttled updates. |
| Gesture-rich surface (instrument, drawing, game, pet a cat) | `.accessibilityDirectTouch(options:)` / UIKit `.allowsDirectInteraction` + `accessibilityDirectTouchOptions` | Touches go straight to the view. Still add custom actions for people who can't perform the gestures. |
| Pinch-to-zoom content | `.accessibilityZoomAction` / UIKit `.supportsZoom` + `accessibilityZoomIn(at:)`/`Out(at:)` | Announce the new zoom level. |
| Drag and drop with several targets | `accessibilityDragPoint` / `accessibilityDropPoint(_:description:)`; UIKit `accessibilityDragSourceDescriptors`/`DropPointDescriptors` | Describe each target ("Set Sound 1"); also offer custom actions when targets are finite. |

### Direct touch options

- `.requiresActivation`: the area ignores touches until the person double-taps, so exploring by touch can't trigger it accidentally. Direct touch then stays active until focus moves away. Use it by default.
- `.silentOnTouch`: VoiceOver stays silent on touch; only for controls that produce their own audio (piano keys).
- The modifier's signature is `accessibilityDirectTouch(_ isDirectTouchArea: Bool = true, options:)`. Write `.accessibilityDirectTouch(options: .requiresActivation)`. The WWDC26 sample's `.accessibilityDirectTouch([.requiresActivation])` doesn't type-check.
- UIKit requires the `.allowsDirectInteraction` trait for `accessibilityDirectTouchOptions` to apply.

### Passthrough and feedback

When someone double-taps and holds, VoiceOver sends touches from the element's activation point. For a fill-level control, place it at the fill height (`UnitPoint(x: 0.5, y: 1 - level)`) so dragging can go either way. Post an announcement when the value changes, but only if it changed and at least about 0.3 seconds have passed since the last one. [WWDC26 220, 7:05](https://developer.apple.com/videos/play/wwdc2026/220/?time=425).

### Custom actions

- SwiftUI: `.accessibilityAction(named: "Move Up") { … }`. The WWDC26 sample's `.accessibilityActions("Move Up") { … }` doesn't exist; `accessibilityActions { … }` takes view content (typically `Button`s) and converts controls into actions—useful for hover overlays, sharing one source of truth with the visible UI.
- `.accessibilityActions(category:)` and UIKit `UIAccessibilityCustomAction.category = .editCategory` (iOS 18) place text-selection actions in VoiceOver's edit rotor.
- UIKit: `UIAccessibilityCustomAction(name:image:actionHandler:)` returning `true` on success. The image appears in Switch Control (otherwise the first letter shows).
- Actions on a combined element come from its children automatically (`children: .combine`). When converting per-row buttons into actions, hide the original buttons from accessibility so they aren't navigated twice. This turned 18 Switch Control activations into 6 in Apple's example. [Making Apps More Accessible With Custom Actions](https://developer.apple.com/videos/play/wwdc2019/250/).
- On macOS, custom actions are less discoverable. Make important hover-only actions real buttons, keyboard shortcuts, or menu items too. In SwiftUI, `accessibilityRepresentation` can expose one view as several buttons; in AppKit, return custom `NSAccessibilityElement` children. [Group Lab, 26:03](https://developer.apple.com/videos/play/wwdc2026/8005/?time=1563).
- Widgets can't run accessibility closures; use `accessibilityAction(named:intent:)` or `accessibilityAction(.magicTap, intent:)` (iOS 18).

## Gesture and pointer interactions

- A tap gesture on non-button content needs the `.isButton` trait—better, use a `Button`. "Learn more" text in the accent color with a chevron is a button to VoiceOver only if you say so.
- Double-tap, long press, swipe, pinch, rotate, multi-finger, and drag interactions each need a single-activation alternative: a custom action, a menu item, an Edit mode, or a visible button. Swipe-to-delete should coexist with an Edit button. [HIG: Accessibility – Mobility](https://developer.apple.com/design/human-interface-guidelines/accessibility).
- Hover-revealed controls (pointer, trackpad, Apple Pencil hover) must also be reachable without hover, for example as actions on the hovered element and keyboard shortcuts.
- Information shown only during interaction (a scrub value, a revealed rating) can be appended to the element's label with `accessibilityLabel { label in … }` (iOS 18), which keeps SwiftUI's derived label.
- For UIKit gesture recognizers that conflict with Zoom, call `UIAccessibility.registerGestureConflictWithZoom()`.

## Shapes, canvases, and drawn content

- SwiftUI: label the `Canvas` and supply `accessibilityChildren { … }` with one view per meaningful item. Large, consistent frames are fine and help touch exploration.
- UIKit: return `UIAccessibilityElement`s from `accessibilityElements`, each with `accessibilityContainer` set to the view and a frame in container space (or `accessibilityFrame` in screen coordinates via `UIAccessibility.convertToScreenCoordinates`).
- AppKit: return `NSAccessibilityElement`s from `accessibilityChildren`; use `accessibilityAddChildElement` and `accessibilityFrameInParentSpace`.
- Custom shapes: `.contentShape(.accessibility, Circle())` (iOS 17) changes the accessibility path without changing hit testing. UIKit `accessibilityPath` (screen coordinates) shapes the VoiceOver and Full Keyboard Access cursor; override its getter inside scroll views.
- Keep values current when the model changes. UIKit block setters (`accessibilityLabelBlock`, `accessibilityValueBlock`, `accessibilityTraitsBlock`…, iOS 17) re-evaluate on each query; capture `self` weakly.

## A worked pattern: star rating

1. Visually five tappable stars; to VoiceOver, five "Filled star, image" elements, which is confusing.
2. Combine into one element labeled "Rating", value "4", adjustable action clamped to 0…5—or `accessibilityRepresentation { Slider(value:in:step:) { Text("Rating") } }`.
3. Result: "Rating, four, adjustable. Swipe up or down…" with every value spoken.

The same element also works for Switch Control (increment and decrement appear in its menu) and Full Keyboard Access. See [AccessibleControls.swift](examples/AccessibleControls.swift).

# Platform-specific accessibility

The element model is shared, but expectations and inputs differ. Test each platform you ship; an accessible iOS screen can still be a poor Mac experience. [Group Lab, 44:58](https://developer.apple.com/videos/play/wwdc2026/8005/?time=2698).

## macOS and Mac Catalyst

- **The keyboard is primary.** Every function must be reachable by keyboard; add shortcuts for common tasks and for jumping between regions. Mac VoiceOver is driven by VO-key commands (Control-Option); toggle it with Command-F5. Triple-press Touch ID (or Option-Command-F5) opens the accessibility shortcuts panel.
- **Hierarchy matters.** VoiceOver moves between containers and interacts into them. Group regions, label containers, avoid both flat lists of hundreds of controls and needlessly deep nesting, and set order with `accessibilitySortPriority`. [Make your Mac app more accessible to everyone](https://developer.apple.com/videos/play/wwdc2025/229/).
- **AppKit.** Standard controls conform to role protocols (`NSAccessibilityButton`, `NSAccessibilitySlider`…). Subclass them when possible. For a custom `NSView` control, conform to the matching protocol (the compiler warns about missing requirements), or implement `accessibilityRole()` and `isAccessibilityElement()`. Represent drawn subparts with `NSAccessibilityElement` children (`accessibilityAddChildElement`, `accessibilityFrameInParentSpace`), convert coordinates with `NSAccessibility.screenRect(fromView:rect:)` and `screenPoint(fromView:point:)`, and post notifications with `NSAccessibility.post(element:notification:)`. [Integrating accessibility into your app](https://developer.apple.com/documentation/accessibility/integrating-accessibility-into-your-app).
- macOS 26 expanded `NSAccessibility` for documents and the web: heading roles and levels, block-quote level, language, visited links, list markers, and dozens of search keys (headings, links, landmarks, tables, misspelled words) for custom document views. macOS 27 adds Show Borders support through SwiftUI's `accessibilityShowBorders`.
- **Mac Catalyst** translates UIKit accessibility automatically. UIKit containers become hierarchical Mac nodes, so container labels and `accessibilityContainerType` matter more. Use `selectionFollowsFocus` for tables and collections, and add `UIKeyCommand` menus. Accessibility Inspector shows the original iOS traits and container types. [Accessibility design for Mac Catalyst](https://developer.apple.com/videos/play/wwdc2020/10117/).
- Hover and trackpad-only interactions need actions, keyboard shortcuts, or visible buttons. Mac users skip custom actions more often than iOS users.

## watchOS

- Use text styles, let text wrap, and switch to stacked layouts at large sizes. Large accessibility sizes exist on the watch (people choose them during setup), and the largest exceeds 140%.
- `NavigationLink` combines its children into one element. Label SF Symbol icons in context ("Watering in five days"), use adjustable actions for steppers and Digital Crown-driven values, and make custom controls single elements.
- **Complications and notifications** are entry points too. Expand abbreviations in labels, label image-based complications, and give dynamic notifications the same accessibility as the app.
- **AssistiveTouch on Apple Watch:** make tappable regions focusable (`accessibilityRespondsToUserInteraction(true)`), size cursor frames with `contentShape`, give actions images, and consider `accessibilityQuickAction` for the primary action. [Create accessible experiences for watchOS](https://developer.apple.com/videos/play/wwdc2021/10223/).
- The Larger Text label applies on watchOS, and the Voice Control label doesn't.

## tvOS

- Navigation is linear with the focus engine and Siri Remote; there's no touch screen and usually no keyboard. Ensure every focusable item has a label and that VoiceOver order follows focus order.
- **tvOS 27 Large Text:** adopt text styles, remove fixed widths, add adaptive layouts (fewer posters per row at accessibility sizes, vertical card layouts, marquee for long titles), and claim Larger Text for tvOS when common tasks pass. [Prepare your tvOS apps for Dynamic Type](https://developer.apple.com/videos/play/wwdc2026/221/).
- Use AVKit for captions and audio descriptions.
- Voice Control and its label aren't available on Apple TV, and the accessibility URL isn't shown on Apple TV product pages.

## visionOS and RealityKit

- SwiftUI and UIKit windows behave as on iOS, but **RealityKit entities have no default accessibility**. Add an `AccessibilityComponent` with `isAccessibilityElement`, label, value, traits (`.button`, `.playsSound`…), `systemActions` (`.activate`, `.increment`, `.decrement`), custom actions, custom content, and rotors. Update values as state changes. Handle activation by subscribing to `AccessibilityEvents.Activate` in the `RealityView` content. [Improving accessibility support in your visionOS app](https://developer.apple.com/documentation/visionos/improving-accessibility-support-in-your-app).
- **VoiceOver gestures:** right index pinch moves to the next item, right middle pinch to the previous item, and right ring or left index pinch activates. Apps don't receive hand input while VoiceOver is on unless the person enables **Direct Gesture mode**. Announce meaningful results—item placement ("Three clouds above and in front of you to the right"), recognized gestures, state and scene changes—and use spatial sound. [Create accessible spatial experiences](https://developer.apple.com/videos/play/wwdc2023/10034/).
- **Head-anchored content** follows the head and conflicts with Zoom, Pointer Control (head), and low-vision users who need to move closer. Prefer world anchors or lazy follow. Keep any head-anchored content decorative, and switch anchors when `@Environment(\.accessibilityPrefersHeadAnchorAlternative)` or `AccessibilitySettings.prefersHeadAnchorAlternative` is true.
- **Inputs:** support Dwell Control's tap, scroll, long press, and drag; Pointer Control (head, wrist, finger); keyboards and game controllers; one-handed play; and menu commands for custom hand gestures. Don't require reaching, crouching, or turning around.
- **Comfort and motion:** keep UI within the field of view and prefer horizontal layouts; avoid peripheral motion, rapid or bouncing movement, zooming, multi-axis movement, spinning, rotating the world, and sustained oscillation near 0.2 Hz. Use fades for relocation, translucency for large moving objects, slow dark-to-bright transitions, and reading content beyond arm's length at a comfortable depth. Offer static alternatives with Reduce Motion. [Design considerations for vision and motion](https://developer.apple.com/videos/play/wwdc2023/10078/), [HIG: Motion](https://developer.apple.com/design/human-interface-guidelines/motion).
- Caption spatial audio with direction. Ensure at least 4.5:1 text contrast over passthrough or materials.
- Compatible iPhone and iPad apps on Vision Pro show their iPhone and iPad Nutrition Labels.

## Widgets, Live Activities, notifications, and App Intents

- Widgets and Live Activities need labels, combined elements, and correct reading order like any view. Accessibility action closures don't run in widgets; use `accessibilityAction(named:intent:)`.
- Actions from notifications and widgets count as common tasks for Nutrition Labels when they're the usual way to complete a task.
- App Intents and Shortcuts let people run tasks by voice, Action button, or automation—an accessibility multiplier for motor and cognitive disabilities.

## Web content

WebKit exposes semantic HTML and ARIA. Prefer native elements; give custom widgets roles, focusability (`tabindex="0"`), ARIA state kept in sync with visuals, and keyboard handlers. VoiceOver's swipe up/down on an ARIA slider sends ArrowRight/ArrowLeft key events. Use `<dialog>` and `showModal()` with `aria-labelledby` and `autofocus`. Safari's SpeechSynthesis accepts SSML. Safari 27's customizable `<select>` keeps native accessibility. In-app web views inherit WebKit accessibility, but you still own the page's markup and font sizing. [What's new in web accessibility](https://developer.apple.com/videos/play/wwdc2022/10153/).

## Games

- Unity: Apple's open-source Accessibility plug-in (`github.com/apple/unityplugins`) adds `AccessibilityNode` components (label, traits, value delegates, actions), Dynamic Type multipliers, and Reduce Motion, Reduce Transparency, and Increase Contrast checks. [Add accessibility to your Unity games](https://developer.apple.com/videos/play/wwdc2022/10151/).
- Native engines (Metal, SpriteKit, SceneKit, RealityKit) expose elements manually through containers of `UIAccessibilityElement`s or `AccessibilityComponent`.
- Provide remappable controls, game-controller and keyboard support, difficulty and timing accommodations, captions for cutscenes, audio descriptions or narration for visual-only cues, colorblind-safe palettes, and scalable text. Avoid flashing, or honor Dim Flashing Lights. [HIG: Designing for games](https://developer.apple.com/design/human-interface-guidelines/designing-for-games).

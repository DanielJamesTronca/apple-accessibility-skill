# Foundations: elements, descriptions, order, and focus

Assistive technologies (VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Hover Text, Speak Screen, Accessibility Reader, and UI tests) interact with an app only through its **accessibility elements**. SwiftUI derives elements from views; UIKit and AppKit expose them from views or from `UIAccessibilityElement`/`NSAccessibilityElement` objects. Anything that isn't part of an element—a shape, a `Canvas` drawing, a `CATextLayer`, a RealityKit entity, a game-engine sprite—doesn't exist for these users. [Catch up on accessibility in SwiftUI](https://developer.apple.com/videos/play/wwdc2024/10073/), [Accessibility Inspector](https://developer.apple.com/videos/play/wwdc2019/257/).

## The element contract

| Property | Purpose | SwiftUI | UIKit | AppKit |
| --- | --- | --- | --- | --- |
| Label | What the element is or does | `accessibilityLabel` | `accessibilityLabel` | `setAccessibilityLabel` / `accessibilityLabel()` |
| Value | Current state or content | `accessibilityValue` | `accessibilityValue` | `accessibilityValue()` |
| Traits / role | Kind and behavior (button, header, adjustable, selected…) | `accessibilityAddTraits` / `RemoveTraits` | `accessibilityTraits` | `accessibilityRole()`, protocols such as `NSAccessibilityButton` |
| Hint | Optional result of acting, when not obvious | `accessibilityHint` | `accessibilityHint` | `accessibilityHelp()` |
| Actions | Default, adjustable, custom, escape, magic tap | `accessibilityAction…` | `accessibilityActivate()`, `accessibilityCustomActions`… | `accessibilityPerformPress()`… |
| Input labels | Voice Control / Full Keyboard Access synonyms | `accessibilityInputLabels` | `accessibilityUserInputLabels` | `accessibilityUserInputLabels` |
| Identifier | UI-test identity, never spoken | `accessibilityIdentifier` | `accessibilityIdentifier` | `setAccessibilityIdentifier` |

VoiceOver speaks label, value, then traits ("Read the landmark description, completed, button"). A text field reads its label as the field name and its value as the contents ("Title, Towering Peaks, text field"). Use the value, not the label, for anything that changes. [Prepare your app for Accessibility Nutrition Labels](https://developer.apple.com/videos/play/tech-talks/111433/).

Standard SwiftUI controls derive label, value, traits, and actions from their initializer, and keep them when restyled with `buttonStyle`, `toggleStyle`, `labelStyle`, `progressViewStyle`, `gaugeStyle`, and similar. Prefer a style over a hand-built control. A custom `ButtonStyle` that returns only an `Image` discards the configuration label; restore it with `.accessibilityRepresentation { configuration.label }`. [SwiftUI Accessibility: Beyond the basics](https://developer.apple.com/videos/play/wwdc2021/10119/).

## Write labels for the context

- Name the purpose, not the picture: a heart button is "Favorite", not "Heart"; a "+" is "Add" in Notes, "Add to Cart" in a store, and "Add peanut butter to cart" when every row has one. [Writing Great Accessibility Labels](https://developer.apple.com/videos/play/wwdc2019/254/).
- Keep it short and avoid redundancy the context already supplies ("Play", not "Play song", inside a player). Move longer explanations into a hint, and only when the result isn't obvious.
- Never include the element type or state words ("Unsubscribe checkbox, checkbox"); use traits and values. Update labels and values when state changes.
- Make labels understandable out of order—avoid "Learn more" or several identical "Delete" buttons without saying what they affect. [VoiceOver evaluation criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/voiceover-evaluation-criteria).
- Label meaningful animations and progress ("Loading"). Expand abbreviations ("Wednesday, March 9", not "Wed Mar 9").
- Localize every label, value, hint, and custom action name, with plural rules where numbers appear.
- Verify SF Symbol defaults. Many symbols have meaningful default labels (`checkmark.seal.fill` → "Verified"), others fall back to the symbol name ("sparkles"). Since iOS 18, `accessibilityLabel(_:isEnabled:)` applies an override only when needed, keeping the default otherwise.
- Match Voice Control expectations: a label that differs from visible text forces people to say "Show names". Add synonyms with input labels (["Favorite", "Heart", "Like"]).

Images: describe what the image conveys, not nearby captions VoiceOver will also read. Hide decorative images with `Image(decorative:)`, `.accessibilityHidden(true)`, or `isAccessibilityElement = false`. A thumbnail beside its own title in a list is usually decorative there even if the detail page describes it. User-generated images need a way for authors to add alt text. Since iOS 27, VoiceOver can append a system image description after an image's label (preceded by a subtle sound); keep the image trait so people can still reach that description and Image Explorer, rather than stripping it to suppress the AI description. [Accessibility Technologies Group Lab, 9:24](https://developer.apple.com/videos/play/wwdc2026/8005/?time=564).

## Structure: grouping, containers, order

Elements are read in the reading order of the current language (top-leading to bottom-trailing in English); right-to-left languages reverse it. Visual relationships created by proximity or alignment don't exist for VoiceOver until you express them.

| Behavior | SwiftUI | UIKit / AppKit |
| --- | --- | --- |
| One element from several views (labels concatenated, child buttons become custom actions) | `.accessibilityElement(children: .combine)` | `UIAccessibilityElement` with combined label and `accessibilityFrameInContainerSpace` = union of frames |
| New element ignoring children (then set label/value/actions yourself) | `.accessibilityElement()` (default `.ignore`) | `isAccessibilityElement = true` on the container; children hidden |
| Navigable group | `.accessibilityElement(children: .contain)` + container label | `accessibilityContainerType = .semanticGroup` + label; `shouldGroupAccessibilityChildren` |
| Custom order | `.accessibilitySortPriority(_:)` (higher first, default 0) | `accessibilityElements` array order |
| Replace children | `.accessibilityChildren { … }` | `accessibilityElements` of custom elements |

- Combine cells that a sighted person reads as one unit (a flight card, a message with its unread dot and Reply/Favorite buttons, a title/value pair). `ForEach` rows usually want `.combine`.
- Use containers for regions people skip as a whole (a sidebar, an inspector, a list of presets). On macOS containers are hierarchical nodes VoiceOver enters and exits, so they matter more; on iOS the containers rotor jumps between them. Don't over-nest. [Make your Mac app more accessible to everyone](https://developer.apple.com/videos/play/wwdc2025/229/).
- Prioritize context before actions: a "Send Challenge" button should come after the person's name (`accessibilitySortPriority(-1)`).
- Shapes and `Canvas` have no element. Adding `accessibilityLabel` to a shape creates one; an element with opacity 0 is hidden automatically.
- Title every screen uniquely and mark section titles as headers (`.isHeader`, `accessibilityHeading(_:)`). `Section` headers get the trait automatically. [HIG: VoiceOver](https://developer.apple.com/design/human-interface-guidelines/voiceover).

## Focus, changes, and modals

- When content changes without a screen change, post a layout change (optionally with the element to focus); when most of the screen changes, post a screen change; for status that shouldn't move focus, post an announcement. In Swift use `AccessibilityNotification.Announcement`, `.LayoutChanged`, `.ScreenChanged`, `.PageScrolled` (iOS 17/macOS 14); UIKit `UIAccessibility.post(notification:argument:)` works everywhere. [Group Lab, 14:57](https://developer.apple.com/videos/play/wwdc2026/8005/?time=897).
- Announcement priority (iOS 17): set `accessibilitySpeechAnnouncementPriority` on an `AttributedString` (UIKit key `.UIAccessibilitySpeechAttributeAnnouncementPriority`). High interrupts and can't be interrupted; default interrupts but can be; low queues and may be dropped. Throttle repeated announcements (Apple uses roughly 0.3 s and "value changed" checks). [Build accessible apps with SwiftUI and UIKit](https://developer.apple.com/videos/play/wwdc2023/10036/).
- `@AccessibilityFocusState` (optionally `for: .voiceOver`) reads or requests assistive focus with `.accessibilityFocused`. Move focus only for high-priority context (an error that blocks progress, a new required step); otherwise announce. Read the focus state before auto-dismissing a banner, and keep it while focused. `accessibilityDefaultFocus(_:_:)` (iOS/macOS 26) suggests initial focus when a scene appears.
- Reloading content must not reset the reading position (for example, a feed loading more rows). Presented content must receive focus, and background content must be unreachable: present modally through the framework, or for a custom overlay set `accessibilityViewIsModal = true` and post a screen change. Support dismissal with the escape gesture (`accessibilityPerformEscape`, `.accessibilityAction(.escape)`).
- A long press, context menu, or hover reveal needs an action equivalent (VoiceOver's actions rotor, or VO-Shift-M on Mac). [Deliver an Exceptional Accessibility Experience](https://developer.apple.com/videos/play/wwdc2018/230/).

## Representables, web views, and hybrid UI

Expose labels and elements from `UIViewRepresentable`/`NSViewRepresentable` content in the wrapped view. WebKit maps semantic HTML and ARIA to accessibility; prefer native elements, and for custom widgets supply `role`, `tabindex="0"`, ARIA state, and keyboard handling. Use `<dialog>` with `showModal()` for modal focus and escape handling. [What's new in web accessibility](https://developer.apple.com/videos/play/wwdc2022/10153/). Game engines need explicit bridging; see [platforms](platforms.md).

## Prioritize like Apple's accessibility team

Start with VoiceOver: the same element API backs Voice Control, Switch Control, Full Keyboard Access, and UI tests, so a solid VoiceOver experience gets most of the way there. For a data-heavy app, Dynamic Type plus labels is the fastest large win. Test with people who use these technologies when possible; "nothing about us without us." [Group Lab, 6:07](https://developer.apple.com/videos/play/wwdc2026/8005/?time=367), [Principles of inclusive app design](https://developer.apple.com/videos/play/wwdc2025/316/).

Design principles that drive these choices: support multiple senses (visual, audio, haptic, text), offer customization, adopt the accessibility APIs, and track "inclusion debt" as known gaps rather than ignoring them. Accessible interfaces are intuitive, perceivable, and adaptable. [HIG: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility).

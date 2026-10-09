# Cognitive accessibility and Assistive Access

People with cognitive disabilities, neurodivergent people, and anyone tired, stressed, or distracted benefit from interfaces that are simple, predictable, forgiving, and patient. In the US, about one in six children has a developmental disability. [Deliver an Exceptional Accessibility Experience](https://developer.apple.com/videos/play/wwdc2018/230/).

## Design principles for every app

- **Keep actions simple and consistent.** Use system controls and familiar gestures; consistent patterns transfer learning between screens and apps. Custom controls should behave like their closest system counterpart.
- **Make the next step obvious.** Clear cause and effect, few options per screen, plain names. Names should fit the app, set accurate expectations, and survive translation (Apple chose "Balance" over "Spending Power" and "Enhance Dialogue" over "Isolate Vocals"). [Craft clear names for features and labels in your app](https://developer.apple.com/videos/play/wwdc2026/290/).
- **No time pressure.** Avoid auto-dismissing alerts, toasts, and controls; dismiss on explicit action. If a timer is unavoidable, let people extend or disable it.
- **Forgive errors.** Warn before irreversible actions, offer undo, always confirm payments—including one-tap purchases.
- **Avoid hidden interactions.** Hover-reveals, swipe-only actions, and nested menus are hard to discover and remember. Use them only for secondary shortcuts to features that are also visible.
- **Let people control media.** Don't autoplay audio or video without controls, and honor Auto-Play Video Previews (`UIAccessibility.isVideoAutoplayEnabled`) and Animated Images.
- **Offer accommodations in games.** Adjustable difficulty, reaction time, and control assistance.
- **Support multiple senses and customization.** Text with images, audio with captions, dense versus simplified layouts (Carrot Weather's minimal mode is Apple's example). [Principles of inclusive app design](https://developer.apple.com/videos/play/wwdc2025/316/).
- **Work with Speak Screen, Speak Selection, and Accessibility Reader.** These read content aloud with highlighting and present text in a person's preferred style; proper text semantics make them work (see [navigation and reading](navigation-and-reading.md)).

## Assistive Access (iOS and iPadOS 17+)

Assistive Access is a distilled system experience for people with cognitive disabilities, set up by a trusted supporter: large icons and text, a grid or row layout, a persistent Back button at the bottom, and simplified Apple apps (Calls, Messages, Camera, Photos, Music, and the TV app in 27). Third-party apps run inside it. [Meet Assistive Access](https://developer.apple.com/videos/play/wwdc2023/10032/), [Customize your app for Assistive Access](https://developer.apple.com/videos/play/wwdc2025/238/).

| Option | When | How |
| --- | --- | --- |
| Do nothing | Most apps | The system draws the app in a reduced frame (the size of a smaller device) above the Back button. Test that it works. |
| Full screen with existing UI (iOS 17) | Apps already designed for cognitive disabilities, such as AAC apps, with adaptive layouts | `UISupportsFullScreenInAssistiveAccess = YES`. Use safe areas and layout guides; never assume screen sizes. |
| Streamlined scene (iOS/iPadOS 26) | Everyone else who wants an optimized experience; the recommended choice when unsure | `UISupportsAssistiveAccess = YES` plus a SwiftUI `AssistiveAccess { … }` scene |

Both keys list the app as "Optimized" in Assistive Access settings so trusted supporters can find it.

Building the scene:

- Declare `AssistiveAccess { AssistiveAccessContentView() }` alongside `WindowGroup`. When active, standard SwiftUI buttons, lists, navigation links, and titles automatically use the large Assistive Access style and the configured grid or row layout, and the system Back button walks the navigation stack.
- UIKit-lifecycle apps declare the scene in the `static var rootScene` of an `NSObject` subclass conforming to the `UIHostingSceneDelegate` protocol (the session's `class …: UIHostingSceneDelegate` doesn't compile) and return that delegate class when `connectingSceneSession.role == .windowAssistiveAccessApplication` in `application(_:configurationForConnecting:options:)`.
- Preview with `#Preview(traits: .assistiveAccess)`.
- Give every navigation title an icon: `.assistiveAccessNavigationIcon(systemImage:)` or `(_ image:)`. Pair every button and link with icon and text.
- For small adjustments inside existing UI, read `@Environment(\.accessibilityAssistiveAccessEnabled)` (iOS 18) or `AccessibilitySettings.isAssistiveAccessEnabled`, and remove workflows that don't fit.

Designing the experience:

1. Pick the one or two core tasks; leave everything else out.
2. Show few options per screen and keep controls visible: no hidden gestures, edge swipes, or nested menus. Edge-swipe gestures are disabled in Assistive Access, so swipe-only navigation breaks.
3. Guide step by step: split decisions into separate screens in a sensible order (choose a color, then draw).
4. Remove or double-confirm destructive actions such as delete; Apple's sample dropped undo and delete entirely.
5. Don't depend on timing.
6. Test with the Assistive Access community.

See [AssistiveAccessScene.swift](examples/AssistiveAccessScene.swift).

## Guided Access

Guided Access is a cognitive-accessibility feature as much as a kiosk tool: it keeps someone inside one app with optional touch and hardware restrictions. Add custom restrictions for areas where people could get lost or make unintended changes (account settings, purchases). See [input alternatives](input-alternatives.md#guided-access-and-single-app-modes).

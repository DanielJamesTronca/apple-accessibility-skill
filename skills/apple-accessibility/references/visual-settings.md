# Visual settings: contrast, color, transparency, and motion

Vision is a spectrum: low vision, color blindness, light sensitivity, motion sensitivity, and situational limits like glare. People choose display accommodations in Settings; your app should look correct with each one, alone and combined. System colors, materials, Liquid Glass, and standard controls adapt automatically—custom colors, blurs, and animations are where apps break. [Make your app visually accessible](https://developer.apple.com/videos/play/wwdc2020/10020/).

## Settings and how to read them

| Setting | SwiftUI | UIKit / Accessibility | AppKit |
| --- | --- | --- | --- |
| Increase Contrast | `@Environment(\.colorSchemeContrast) == .increased` | `traitCollection.accessibilityContrast == .high`; `UIAccessibility.isDarkerSystemColorsEnabled` | `NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast` |
| Reduce Transparency | `\.accessibilityReduceTransparency` | `UIAccessibility.isReduceTransparencyEnabled` | `…accessibilityDisplayShouldReduceTransparency` |
| Reduce Motion | `\.accessibilityReduceMotion` | `UIAccessibility.isReduceMotionEnabled` | `…accessibilityDisplayShouldReduceMotion` |
| Prefer Cross-Fade Transitions | `\.accessibilityPrefersCrossFadeTransitions` (iOS 26.4) | `UIAccessibility.prefersCrossFadeTransitions` (iOS 14) | — |
| Differentiate Without Color | `\.accessibilityDifferentiateWithoutColor` | `UIAccessibility.shouldDifferentiateWithoutColor` | `…accessibilityDisplayShouldDifferentiateWithoutColor` |
| Button Shapes / Show Borders | `\.accessibilityShowBorders` (renamed from `accessibilityShowButtonShapes`; back-deployed, macOS 27 honors it too) | `UIAccessibility.buttonShapesEnabled`; `AccessibilitySettings.showBordersEnabled` (26.1) | `AccessibilitySettings.showBordersEnabled` (macOS 26.1); no `NSWorkspace` property |
| Bold Text | `\.legibilityWeight == .bold` | `UIAccessibility.isBoldTextEnabled` | — |
| Smart Invert / Invert Colors | `\.accessibilityInvertColors`; `.accessibilityIgnoresInvertColors()` | `UIAccessibility.isInvertColorsEnabled`; `accessibilityIgnoresInvertColors` | `…accessibilityDisplayShouldInvertColors` |
| Dim Flashing Lights | `\.accessibilityDimFlashingLights` | `MADimFlashingLightsEnabled()` + `kMADimFlashingLightsChangedNotification` | same (MediaAccessibility) |
| Animated Images (off = pause GIFs) | `\.accessibilityPlayAnimatedImages` | `AccessibilitySettings.animatedImagesEnabled` (iOS 18) | same |
| Auto-Play Video Previews | — | `UIAccessibility.isVideoAutoplayEnabled` | — |
| Reduce Highlighting Effects | `\.accessibilityReduceHighlightingEffects` (26.4) | `AccessibilitySettings.isReduceHighlightingEffectsEnabled` | same |
| Grayscale, On/Off Labels, Mono Audio | — | `isGrayscaleEnabled`, `isOnOffSwitchLabelsEnabled`, `isMonoAudioEnabled` | — |

SwiftUI environment values update views automatically. In UIKit, observe the matching `…StatusDidChangeNotification` (or the iOS 26 typed `NotificationCenter` messages such as `UIAccessibility.ReduceMotionStatusDidChangeMessage`) or register for trait changes (`UITraitAccessibilityContrast`, `UITraitLegibilityWeight`).

## Contrast

- Minimums Accessibility Inspector applies (WCAG AA): 4.5:1 for text up to 17 pt, 3:1 for 18 pt and larger or bold text. Aim for 3:1 for meaningful non-text elements and state indicators, such as a custom checkbox's checked versus unchecked appearance. APCA is another accepted measure. [HIG: Accessibility – Vision](https://developer.apple.com/design/human-interface-guidelines/accessibility).
- Meet the minimum by default where possible. If the brand palette can't, make Increase Contrast deliver it: system colors gain accessible variants automatically; for custom colors add **High Contrast** appearances in the asset catalog. Rule of thumb: in light mode, foregrounds get darker; in dark mode, lighter.
- Check light and dark appearances, with Increase Contrast on and off and Reduce Transparency on and off. Gray-on-black "comfortable" dark reading themes often fail low-vision users.
- Translucency counts: text over blur or video varies in contrast. Liquid Glass and system materials become frostier or fully opaque with Reduce Transparency and gain borders and black/white foregrounds with Increase Contrast, automatically. Custom translucent views must check Reduce Transparency and switch to opaque fills. The Clear Liquid Glass variant needs a dimming layer for legibility. [Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/).
- Measure with Accessibility Inspector's Color Contrast Calculator (Window > Show Color Contrast Calculator, ⌥⌘C) or `performAccessibilityAudit(for: .contrast)`.

## Color and meaning

- Never use color as the only carrier of meaning—status dots, chart series, form errors, selected tabs, game teams. Add shape, symbol, text, pattern, or position. Ideally this is the default design. Otherwise add the extra cues when Differentiate Without Color is on, or offer alternate palettes. [Differentiate Without Color Alone criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/differentiate-without-color-alone-evaluation-criteria).
- Avoid red/green and blue/yellow pairings for distinctions. Test with the Grayscale filter and the color filters for protanopia, deuteranopia, and tritanopia (Settings > Accessibility > Display & Text Size > Color Filters).
- `"\(accessibilityName: color)"` (iOS 18) and `AXNameFromColor(_:)` produce localized color names when color itself is content (paint pickers, product variants).
- With Button Shapes/Show Borders on, give custom borderless buttons a visible boundary or underline.

## Dark interface and inversion

- Support Dark Mode with semantic colors and dark variants; avoid bright full-screen flashes while dark (launch screens, web content, image placeholders). A light-sensitive person needs the interface to stay dark, not just start dark. [Dark Interface criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/dark-interface-evaluation-criteria).
- Smart Invert inverts your UI: mark photos, video, maps, and app or brand imagery with `accessibilityIgnoresInvertColors` so media isn't inverted. Check that semantic color meaning (a red Delete button) survives.

## Motion

People with vestibular disorders can feel dizziness or nausea from on-screen motion. Common triggers: scaling and zooming transitions; spinning, vortex, and multi-axis motion; plane-shifting 3D effects; parallax and depth-of-field; animated blur; multi-speed or springy motion; peripheral background animation; auto-advancing carousels; auto-playing video. [Deliver an Exceptional Accessibility Experience](https://developer.apple.com/videos/play/wwdc2018/230/), [Reduced Motion criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/reduced-motion-evaluation-criteria).

With Reduce Motion on:

- Remove purely decorative motion (idle loops, parallax via `UIMotionEffect`, background weather effects).
- Replace meaningful motion instead of deleting it: cross-fade, dissolve, highlight, or color change still communicates "added to cart" or "moved to a subview". Tighten springs and avoid bounce, track gestures directly, avoid z-axis depth animation, and avoid animating into or out of blur. [HIG: Accessibility – Cognitive](https://developer.apple.com/design/human-interface-guidelines/accessibility).
- Stop auto-advancing carousels or give a visible pause control. Ask before playing full-screen effects (Messages prompts to replay effects).
- Respect Prefer Cross-Fade Transitions in custom navigation transitions; UIKit's navigation and modal presentations already do.
- SwiftUI: `withAnimation(reduceMotion ? nil : .spring) { … }`, or a fade transition `.transition(reduceMotion ? .opacity : .move(edge: .trailing))`.

Even without the setting: make motion purposeful and brief, let people interrupt it, and never make it the only feedback—pair with haptics or sound. [HIG: Motion](https://developer.apple.com/design/human-interface-guidelines/motion).

## Flashing and blinking

Bright, frequent flashes can trigger seizures. With Dim Flashing Lights on, AVFoundation playback dims detected flashing automatically. Custom video pipelines use `MAFlashingLightsProcessor`. Apps can also annotate flashing segments on a timeline, play alternate assets, or tame game effects. Pause animated images when Animated Images is off, and stop blinking cursors when `prefersNonBlinkingTextInsertionIndicator` is on. [Flashing lights](https://developer.apple.com/documentation/mediaaccessibility/flashing-lights).

## Test combinations

Turn on, one at a time and then together: Bold Text, Larger Accessibility Sizes, Button Shapes, On/Off Labels, Reduce Transparency, Increase Contrast, Differentiate Without Color, Color Filters, Smart Invert, Reduce Motion, Dim Flashing Lights—in light and dark appearance. Accessibility Inspector's Settings pane toggles most of these on a connected simulator or device. See [testing](testing.md) and [AdaptiveAppearance.swift](examples/AdaptiveAppearance.swift).

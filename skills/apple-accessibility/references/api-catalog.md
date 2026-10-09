# API catalog, availability, and corrections

Checked against public documentation and the **Xcode 27.1 (27A9269)** iOS and macOS SDKs on 2026-10-09. Versions are iOS introductions unless noted; macOS, tvOS, watchOS, and visionOS often differ, so check the declaration. This catalog focuses on recent and frequently misused APIs; [foundations](foundations.md) and the topic references cover the long-standing ones.

## iOS 27 / macOS 27

| API | Notes |
| --- | --- |
| `XCUIDevice.voiceOverService` → `XCUIVoiceOverService` | UI-test VoiceOver control: `enable()`, `disable()`, `isEnabled`, `moveForward()`, `moveBackward()`, `currentSpeech()`, and on iOS and macOS `moveIn()`/`moveOut()`. Returns `XCUIVoiceOverService.Output` with `utterance`; errors in `XCUIVoiceOverService.Error`. All platforms 27. |
| `AccessibilitySettings.isApplicationAccessibilityEnabled` + `ApplicationAccessibilityEnabledDidChangeMessage` / `applicationAccessibilityEnabledDidChangeNotification` | Whether application accessibility is active for the process. Don't use it to skip accessibility work. |
| `AttributeScopes.AccessibilityAttributes.accessibilitySpeechSSML` | Attributed-string SSML for speech; all platforms 27. Behavior not covered in sessions; verify. |
| `MACaptionAppearanceDomain.videoConferencing` | iOS and macOS 27; semantics undocumented in the SDK. |
| `Optional`/`TupleContent` conformance to `AccessibilityRotorContent` | Rotor builders now use `ContentBuilder`; `if` inside rotor content requires a 27 deployment target. |
| Behavior: `accessibilityLinkedGroup(id:in:)` links text views for line navigation | Modifier from iOS 14; new behavior in 27. |
| Behavior: tvOS Large Text, generated subtitles, VoiceOver image descriptions | System features; no new API needed. Provide subtitle selection UI and keep image traits. |
| SwiftUI types moved to SwiftUICore (`AccessibilityTechnologies`, `AccessibilityActionCategory`, `AccessibilityAdjustmentDirection`, `AccessibilityZoomGestureAction`, `AccessibilityDirectTouchOptions`…) | `@_originallyDefinedIn(module: "SwiftUI", iOS 27.0)` relocations, not new APIs. Source-compatible. |

## iOS 26.x / macOS 26.x

| API | Version |
| --- | --- |
| `AVLegibleMediaOptionsMenuController`; `AVPlayerLayer.setCaptionPreviewProfileID(_:position:text:)`, `stopShowingCaptionPreview()` | iOS 26.4 |
| `EnvironmentValues.accessibilityPrefersCrossFadeTransitions`, `.accessibilityReduceHighlightingEffects`; `AccessibilitySettings.isReduceHighlightingEffectsEnabled`, `canOpenSettings(for:)`, `Feature.captionStyles` | 26.4 |
| `EnvironmentValues.accessibilityShowBorders` (renames `accessibilityShowButtonShapes`; `@backDeployed(before: 26.1)` so it works from iOS 14); `AccessibilitySettings.showBordersEnabled`, `prefersActionSliderAlternative` (+ notifications) | 26.1 |
| SwiftUI `AssistiveAccess` scene, `assistiveAccessNavigationIcon(_:)`/`(systemImage:)`, `Info.plist UISupportsAssistiveAccess`, `UISceneSession.Role.windowAssistiveAccessApplication` | 26.0 |
| `accessibilityDefaultFocus(_:_:)`, `accessibilityScrollStatus(_:isEnabled:)`, `safeAreaBar(edge:)` | 26.0 |
| UIKit typed messages: `UIAccessibility.VoiceOverStatusDidChangeMessage`, `ReduceMotionStatusDidChangeMessage`, `ElementFocusedMessage`, `AnnouncementDidFinishMessage`, and others | 26.0 |
| `AccessibilitySettings.Feature.assistiveTouch`, `.assistiveTouchDevices`, `.dwellControl` | 26.0 |
| `AXBrailleTranslator`, `AXBrailleTable`, `AXBrailleTranslationResult` | 26.0 |
| MediaAccessibility caption profiles: `MACaptionAppearanceCopyProfileIDs`, `…SetActiveProfileID`, `…CopyActiveProfileID`, `…CopyProfileName` | 26.0 |
| macOS 26 `NSAccessibility`: heading role and level, block quote level, language, visited, list marker role, web area role, suggestion subrole, scroll-to-visible action, many `NSAccessibilitySearchKey`s | macOS 26.0 |

## iOS 18.x

| API | Version |
| --- | --- |
| `AXFeatureOverrideSessionManager` (merchant entitlement), `AXMathExpression*` | 18.2 (macOS 15.2 for math) |
| `UIAccessibility…TextInputResponder` (`accessibilityTextInputResponder`) | 18.1 |
| `accessibilityLabel(_:isEnabled:)` and other `isEnabled:` variants; `accessibilityLabel(content:)`; `"\(accessibilityName:)"`; `accessibilityAction(named:intent:)` / `(_:intent:)` | 18.0 |
| `AccessibilityTraits.isTabBar` / `UIAccessibilityTraits.tabBar` | 18.0 |
| `accessibilityNext/PreviousTextNavigationElement` (not tvOS or watchOS), `UIAccessibilityCustomAction.category` / `.editCategory`, `accessibilityExpandedStatus`, `accessibilityHitTest(_:event:)` | 18.0 |
| `AccessibilitySettings.openSettings(for:)`, `animatedImagesEnabled`, `isAssistiveAccessEnabled`, `prefersNonBlinkingTextInsertionIndicator`; SwiftUI `\.accessibilityAssistiveAccessEnabled` | 18.0 |
| Music Haptics: `MAMusicHapticsManager`, `MusicHapticsSupported` | 18.0 |

## iOS 17

`AccessibilityNotification` (Announcement, LayoutChanged, ScreenChanged, PageScrolled) and announcement priority; `.isToggle` / `.toggleButton`; `accessibilityZoomAction` / `.supportsZoom`; `accessibilityDirectTouch(_:options:)` / `accessibilityDirectTouchOptions`; `contentShape(.accessibility, …)`; UIKit block-based attribute setters; `XCUIApplication.performAccessibilityAudit(for:_:)`; `automationElements`; `UISupportsFullScreenInAssistiveAccess`; Personal Voice authorization; `AVSpeechUtterance(ssmlRepresentation:)`; `MAFlashingLightsProcessor`; `\.accessibilityPlayAnimatedImages`.

## Frequently assumed but older

`accessibilityRepresentation`, `accessibilityChildren`, `accessibilityActions { … }` (iOS 16), `accessibilityRotor`, `AccessibilityFocusState`, `accessibilityCustomContent`, `accessibilityChartDescriptor`, `accessibilityTextContentType`, `accessibilityHeading`, `accessibilityLinkedGroup` (iOS 15, or 14 for some); `AXChart`/`AXCustomContent`/`AccessibilitySettings` (Accessibility framework, iOS 14 and later; `AXLiveAudioGraph` 15; `AXBrailleMap` 15.2); `accessibilityUserInputLabels`, `UILargeContentViewerInteraction`, `shouldDifferentiateWithoutColor`, `isVideoAutoplayEnabled` (iOS 13); `prefersCrossFadeTransitions`, `buttonShapesEnabled`, custom-action images, `prefersAssistiveTechnologySettings` (iOS 14); `accessibilityQuickAction` (watchOS 9).

## Corrections to session sample code

| Session code | What compiles | Evidence |
| --- | --- | --- |
| `.accessibilityActions("Move Up") { … }` (WWDC26 220) | `.accessibilityAction(named: "Move Up") { … }` | SDK: `accessibilityActions` takes `@ContentBuilder` content only |
| `.accessibilityDirectTouch([.requiresActivation])` (WWDC26 220) | `.accessibilityDirectTouch(options: .requiresActivation)` | SDK signature `accessibilityDirectTouch(_ isDirectTouchArea: Bool = true, options:)` |
| `ForEach { if … { AccessibilityRotorEntry(…) } }` (WWDC21 10119, WWDC25 229) with targets below iOS 27 | Filter first: `ForEach(items.filter { … }) { AccessibilityRotorEntry(…) }` | Type-checked against iOS 17, 26, and 27 targets with Xcode 27.1 |
| `.accessibilityCustomContent("Age", age)` with a `String` variable | `.accessibilityCustomContent(.age, age)` using an `AccessibilityCustomContentKey`, or `Text` arguments | Ambiguous overloads in the Xcode 27.1 SDK for iOS 17 and 27 targets |
| `switch direction { case .increment: … case .decrement: … }` | Add `@unknown default` defensively | `AccessibilityAdjustmentDirection` is a non-frozen public enum |
| WWDC22 10151 Unity sample: `reduceMotionOn = !IsReduceMotionEnabled`, then animates when `!reduceMotionOn` | Animate only when Reduce Motion is **off** | Logic inverted in the sample |
| `class AssistiveAccessSceneDelegate: UIHostingSceneDelegate` (WWDC25 238) | `@MainActor final class AssistiveAccessSceneDelegate: NSObject, UIHostingSceneDelegate` with `nonisolated static var rootScene` (Swift 6) | `UIHostingSceneDelegate` is a protocol refining `UISceneDelegate` |
| WWDC23 10036 `NavigationView` | `NavigationStack` in current SwiftUI | `NavigationView` is deprecated |

## Platform notes

- `accessibilityPrefersHeadAnchorAlternative` exists only on visionOS.
- Text navigation element APIs aren't available on tvOS or watchOS. `UIAccessibilityCustomAction.category` is unavailable on watchOS.
- `AccessibilitySettings` lives in the Accessibility framework (`import Accessibility`), not UIKit.
- Mac Catalyst inherits UIKit accessibility; check `API_UNAVAILABLE(macCatalyst)` in headers before using iOS-only APIs. The compile script checks the examples against Catalyst.

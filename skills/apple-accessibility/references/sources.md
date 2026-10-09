# Research coverage and maintenance

Checked **2026-10-09** with **Xcode 27.1 (27A9269)** and the iOS 27.1 and macOS 27.1 SDKs. The skill contains original guidance and original examples; Apple documentation, recordings, and sample code keep their own rights. Apple neither authored nor endorses this skill.

## Core source coverage

| Source | Material examined | Where applied |
| --- | --- | --- |
| [Accessibility framework documentation](https://developer.apple.com/documentation/accessibility) | Full crawl of the topic tree (254 pages): articles, sample-code articles, `AccessibilitySettings`, `AccessibilityNotification`, AX chart/braille/math/custom-content/override/hearing APIs, [Accessibility updates](https://developer.apple.com/documentation/updates/accessibility) | All references; [API catalog](api-catalog.md) |
| SwiftUI, UIKit, AppKit, XCUIAutomation, MediaAccessibility, AVFAudio speech, RealityKit, Foundation accessibility docs | Crawl of accessibility-related pages (about 1,760), including the SwiftUI accessibility collections and *Accessibility for UIKit/AppKit* | Framework tables and examples |
| [Improving accessibility support in your visionOS app](https://developer.apple.com/documentation/visionos/improving-accessibility-support-in-your-app) | Full article | [platforms](platforms.md) |
| [HIG: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility), [VoiceOver](https://developer.apple.com/design/human-interface-guidelines/voiceover), [Inclusion](https://developer.apple.com/design/human-interface-guidelines/inclusion), [Typography](https://developer.apple.com/design/human-interface-guidelines/typography), [Color](https://developer.apple.com/design/human-interface-guidelines/color), [Motion](https://developer.apple.com/design/human-interface-guidelines/motion) and 38 related pages | DocC JSON rendered to text (June 9, 2025 Accessibility change log) | Sizes, contrast, targets, motion, cognitive and visionOS guidance |
| [App Store Connect: Manage app accessibility](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels) | Overview, management steps, and all nine evaluation-criteria pages | [nutrition labels](nutrition-labels.md) |
| WWDC26: [Refine accessibility for custom controls (220)](https://developer.apple.com/videos/play/wwdc2026/220/), [Enhance the accessibility of your reading app (219)](https://developer.apple.com/videos/play/wwdc2026/219/), [Prepare your tvOS apps for Dynamic Type (221)](https://developer.apple.com/videos/play/wwdc2026/221/), [Discover generated subtitles and subtitle styles (256)](https://developer.apple.com/videos/play/wwdc2026/256/), [Accessibility Technologies Group Lab (8005)](https://developer.apple.com/videos/play/wwdc2026/8005/), [Craft clear names (290)](https://developer.apple.com/videos/play/wwdc2026/290/) | Full transcripts and code; accessibility passages of the State of the Union, SwiftUI, UIKit, visionOS, Xcode, Device Hub, TextKit, and games sessions | Current behavior, new APIs, testing, platform notes |
| [Prepare your app for Accessibility Nutrition Labels (tech talk 111433)](https://developer.apple.com/videos/play/tech-talks/111433/) | Page transcript to 22:39, then the official Spanish caption track for the rest (the English captions are empty after 22:39) | Labels, Dynamic Type, color, Liquid Glass |
| WWDC25: [Evaluate your app for Accessibility Nutrition Labels (224)](https://developer.apple.com/videos/play/wwdc2025/224/), [Principles of inclusive app design (316)](https://developer.apple.com/videos/play/wwdc2025/316/), [Customize your app for Assistive Access (238)](https://developer.apple.com/videos/play/wwdc2025/238/), [Make your Mac app more accessible (229)](https://developer.apple.com/videos/play/wwdc2025/229/) | Full transcripts and code | Labels, cognitive, macOS |
| WWDC24: [Catch up on accessibility in SwiftUI (10073)](https://developer.apple.com/videos/play/wwdc2024/10073/), [Get started with Dynamic Type (10074)](https://developer.apple.com/videos/play/wwdc2024/10074/) | Full transcripts and code | SwiftUI and Dynamic Type |
| WWDC23: [Build accessible apps (10036)](https://developer.apple.com/videos/play/wwdc2023/10036/), [Perform accessibility audits (10035)](https://developer.apple.com/videos/play/wwdc2023/10035/), [Create accessible spatial experiences (10034)](https://developer.apple.com/videos/play/wwdc2023/10034/), [Design considerations for vision and motion (10078)](https://developer.apple.com/videos/play/wwdc2023/10078/), [Meet Assistive Access (10032)](https://developer.apple.com/videos/play/wwdc2023/10032/), [Extend Speech Synthesis (10033)](https://developer.apple.com/videos/play/wwdc2023/10033/) | Full transcripts (English HLS captions where the page transcript was incomplete) | iOS 17 APIs, testing, visionOS, speech |
| WWDC22: [Unity games (10151)](https://developer.apple.com/videos/play/wwdc2022/10151/), [Single App Mode (10152)](https://developer.apple.com/videos/play/wwdc2022/10152/), [Web accessibility (10153)](https://developer.apple.com/videos/play/wwdc2022/10153/) | Full transcripts and code | Games, kiosks, web |
| WWDC21: [Beyond the basics (10119)](https://developer.apple.com/videos/play/wwdc2021/10119/), [Full Keyboard Access (10120)](https://developer.apple.com/videos/play/wwdc2021/10120/), [Data-rich apps (10121)](https://developer.apple.com/videos/play/wwdc2021/10121/), [Charts (10122)](https://developer.apple.com/videos/play/wwdc2021/10122/), [watchOS (10223)](https://developer.apple.com/videos/play/wwdc2021/10223/) | Full transcripts and captions | Rotors, focus, keyboard, custom content, charts, watchOS |
| WWDC20: [Visually accessible (10020)](https://developer.apple.com/videos/play/wwdc2020/10020/), [Switch Control (10019)](https://developer.apple.com/videos/play/wwdc2020/10019/), [Custom rotors (10116)](https://developer.apple.com/videos/play/wwdc2020/10116/), [Mac Catalyst (10117)](https://developer.apple.com/videos/play/wwdc2020/10117/), [Speech (10022)](https://developer.apple.com/videos/play/wwdc2020/10022/) | Full transcripts and code | Visual settings, motor, Mac, speech |
| WWDC19 (254, 250, 261, 244, 248, 257) and WWDC18 (230) | Full transcripts | Labels, actions, Large Content Viewer, reading, Inspector, exceptional experience |

[source-index.json](source-index.json) records the documentation articles, HIG pages, App Store Connect pages, sessions, and forum threads actually retrieved, with URLs and dates. In total, 2,018 public documentation pages were retrieved as Markdown or DocC JSON; the index lists the article-level pages. It is provenance, not a substitute for the installed SDK.

Inventoried but not distilled: WWDC21 *The process/practice of inclusive design* (10304, 10275), WWDC17 *Convenience for You is Independence for Me* (110), WWDC19 *Accessibility in SwiftUI* (238, superseded by later SwiftUI sessions), WWDC22 *Get it right (to left)* (10107), and non-accessibility parts of WWDC26 sessions.

## SDK cross-checks

Swift interfaces and headers for SwiftUI, SwiftUICore, UIKit, AppKit, Accessibility, MediaAccessibility, AVFAudio, AVKit, AppIntents' SwiftUI overlay, and XCUIAutomation were inspected. A probe file using every API this skill recommends was type-checked against an iOS 17 deployment target with availability gates, and the shipped examples are type-checked by `scripts/check_examples.sh`. Xcode 27.1 doesn't bundle a VoiceOver or Dynamic Type agent skill: the exported Xcode skills are `app-resizability`, `swiftui-specialist`, and others, plus an Assistive Access document in `IDEIntelligenceChat`. Apple announced accessibility "specialist" skills at WWDC26; when the project's Xcode provides them, prefer the matching-version Apple guidance where it overlaps.

## Resolve conflicts explicitly

| Conflict | Chosen evidence and consequence |
| --- | --- |
| WWDC26 220 code uses `.accessibilityActions("Move Up")` and `.accessibilityDirectTouch([.requiresActivation])` | SDK signatures: `accessibilityAction(named:)` and `accessibilityDirectTouch(options:)` |
| WWDC21/25 rotor samples use `if` inside `ForEach` | Fails below iOS 27 with the Xcode 27 SDK; filter the collection instead (verified) |
| WWDC26 219 says "starting in iOS 27, `accessibilityLinkedGroup`…" | The modifier exists since iOS 14; the text-navigation behavior is what's new |
| Testing article: VoiceOver isn't available in Simulator | Xcode 27 adds a Device Hub VoiceOver toggle and `XCUIVoiceOverService`; a forum report says gestures weren't supported early in the beta. Treat the simulator as supplementary and verify on device |
| `accessibilityShowButtonShapes` in older material | Renamed `accessibilityShowBorders`, back-deployed; macOS 27 honors it |
| Sessions describe new SwiftUI accessibility types in iOS 27 interfaces | They're `@_originallyDefinedIn` relocations to SwiftUICore, not new APIs |
| HIG contrast 4.5:1 vs. a visionOS session's "at least 4:1" | Follow the HIG and Accessibility Inspector (WCAG AA): 4.5:1 for small text |
| Unity sample sets `reduceMotionOn = !IsReduceMotionEnabled` | Inverted logic; animate only when Reduce Motion is off |
| Removing the image trait to suppress VoiceOver's generated image description | Accessibility QA engineer: keep the trait so people can use image descriptions and Image Explorer |

Prefer the selected SDK for declarations and availability, current documentation and App Store Connect criteria for contracts, recent Apple engineer statements for behavior, and recorded sessions for rationale. Label inference explicitly.

## Access and validation limits

- The WWDC26 Accessibility & Inclusion forum Q&A recap couldn't be retrieved (the forums require browser verification, and no public summary was found). Only individual threads were read; they aren't treated as Apple guidance unless staff answered.
- The English caption track of tech talk 111433 is empty after 22:39; the remainder came from Apple's Spanish track.
- No standalone watchOS accessibility article was found (a guessed URL returned 404); watchOS guidance comes from WWDC21 10223, the HIG, and the criteria pages.
- `accessibilitySpeechSSML`, the `videoConferencing` caption domain, and `isApplicationAccessibilityEnabled` were verified only as declarations; their behavior wasn't exercised.
- Examples are type-checked, not run with assistive technologies. Rendered layout, spoken output, and device behavior must be verified in the consuming app.

## Updating the skill

1. Revisit [Accessibility updates](https://developer.apple.com/documentation/updates/accessibility), the HIG change logs, App Store Connect criteria, the accessibility video topic, and the new SDK each release.
2. Retrieve public documentation as Markdown (`<url>.md`) or DocC JSON (`/tutorials/data/<path>.json`); retrieve sessions from page transcripts and, when incomplete, the official HLS caption tracks. Don't publish copied transcripts.
3. Type-check new or renamed symbols against the selected SDK with a minimum deployment target; record introduction versions and relocations in the [API catalog](api-catalog.md).
4. Update the owning reference, this ledger, and `source-index.json`. Resolve contradictions here instead of repeating rules.
5. Run the package validator, the audit tests, and the example compile check. Exercise the behavioral scenarios in `tests/skill_evals.json` after substantial instruction changes.

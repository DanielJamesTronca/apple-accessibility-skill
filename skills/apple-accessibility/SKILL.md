---
name: apple-accessibility
description: Design, implement, review, and test accessibility in SwiftUI, UIKit, AppKit, RealityKit, watchOS, tvOS, and visionOS apps. Use for VoiceOver, Voice Control, Switch Control, keyboard access, Dynamic Type, contrast and motion settings, captions, Assistive Access, accessibility audits, and Accessibility Nutrition Labels. Not for web-only or non-Apple accessibility work.
license: MIT
---

# Apple Accessibility

Make every task in the app possible with any assistive technology or display setting. Prefer standard components and system settings, give custom UI the same semantics a system control has, and verify with real assistive technologies instead of trusting a build or an audit.

Research baseline: **2026-10-09**, Xcode **27.1 (27A9269)**, iOS/macOS 27.1 SDKs. Consult [sources](references/sources.md) for provenance, conflicts, and update rules. Introduction versions are in the [API catalog](references/api-catalog.md); check them against the project's selected SDK and deployment targets.

## Choose the relevant references

Read only what the task needs:

| Task | Reference |
| --- | --- |
| Labels, values, traits, hints, grouping, order, focus, announcements, modals | [foundations](references/foundations.md) |
| Custom controls, gestures, sliders, canvases, drag and drop, hover-only UI | [custom controls](references/custom-controls.md) |
| Rotors, headings, Mac containers, data-rich cells, long-form text, reading apps | [navigation and reading](references/navigation-and-reading.md) |
| Dynamic Type, custom fonts, truncation, layout at accessibility sizes, Large Content Viewer | [Dynamic Type](references/dynamic-type.md) |
| Contrast, Increase Contrast, Dark Mode, color, transparency, motion, flashing, Bold Text | [visual settings](references/visual-settings.md) |
| Voice Control, Switch Control, Full Keyboard Access, AssistiveTouch, hit targets, timing | [input alternatives](references/input-alternatives.md) |
| Assistive Access, Guided Access, single-app kiosks, cognitive load | [cognitive accessibility](references/cognitive.md) |
| Captions, generated subtitles, audio descriptions, speech synthesis, haptics, hearing devices | [media and speech](references/media-and-speech.md) |
| Charts, audio graphs, data tables, braille maps | [charts and data](references/charts-and-data.md) |
| macOS/Catalyst, watchOS, tvOS, visionOS/RealityKit, widgets, web content, games | [platforms](references/platforms.md) |
| Accessibility Inspector, audits in UI tests, VoiceOver automation, manual test matrix | [testing](references/testing.md) |
| Evaluating or claiming App Store Accessibility Nutrition Labels | [nutrition labels](references/nutrition-labels.md) |
| Exact symbols, availability, relocations, and corrected session code | [API catalog](references/api-catalog.md) |

Compile-checked examples accompany the references: [SwiftUI controls](references/examples/AccessibleControls.swift), [adaptive appearance](references/examples/AdaptiveAppearance.swift), [UIKit](references/examples/UIKitAccessibility.swift), [reading content](references/examples/ReadingContent.swift), [AppKit](references/examples/AppKitAccessibility.swift), [Assistive Access](references/examples/AssistiveAccessScene.swift), [audio graph](references/examples/AudioGraph.swift), [media](references/examples/MediaAccessibility.swift), and [UI tests](references/examples/AccessibilityUITests.swift). They demonstrate API contracts, not finished apps.

## Workflow

1. **Establish scope.** Identify platforms, UI frameworks, selected SDK, deployment targets, and what the person asked for: a review, a fix, a feature, or a label claim. List the app's common tasks (first launch, sign-in, purchase, settings, and the primary features) because every judgment is "can someone finish this task?"
2. **Inspect before editing.** Read the affected views and their state owners. Separate standard controls (usually accessible already) from custom drawing, gesture-driven views, representables, web content, RealityKit entities, and game engines (usually not). For an existing project, the optional audit below finds lexical candidates.
3. **Fix in impact order.** Blockers first: anything a VoiceOver, Voice Control, Switch Control, or keyboard user cannot reach, understand, or operate. Then text that cannot grow or is cut off, information carried only by color, motion, or sound, missing setting adaptations, and finally efficiency (grouping, rotors, custom content, shortcuts). VoiceOver work also fixes most Voice Control and Switch Control issues; it does not fix layout, color, or media.
4. **Implement the smallest correct change.** Prefer system components, styles, and settings over custom reimplementation. Keep the visual design unless it causes the barrier. Gate newer APIs for the project's deployment targets. Do not raise deployment targets, rewrite navigation, or remove features to make an example compile.
5. **Verify honestly.** Build the affected target. Use previews or the simulator for Dynamic Type and appearance variants, Accessibility Inspector or `performAccessibilityAudit` for regressions, and a device with VoiceOver (and other relevant technologies) for interaction. Report which checks ran, which need hardware or a person, and what remains unverified. A clean audit or compile is not proof of accessibility.

For a review, report the affected task, element, file/line, evidence, who is blocked, and the smallest fix. For a Nutrition Label question, follow [nutrition labels](references/nutrition-labels.md) and decide per device and per feature.

## Invariants

- Every interactive or meaningful element has a concise, localized label that names its purpose, plus the value and traits a sighted person infers visually. Labels don't repeat the role ("button") or state ("selected"); traits and values carry those.
- Custom controls expose purpose, value, actions, and feedback. Use `accessibilityRepresentation` or adjustable actions before bespoke workarounds. Every gesture, hover, long press, drag, or multi-finger interaction also has an accessible action or visible alternative—even with direct touch.
- Nothing important is conveyed only by color, motion, sound, position, or a timeout. Respect Reduce Motion, Increase Contrast, Reduce Transparency, Differentiate Without Color, Bold Text, Dim Flashing Lights, and captions preferences, and pair audio cues with visual and haptic feedback.
- Text uses text styles or scaled custom fonts, wraps instead of truncating essential content, and reflows at accessibility sizes. The Large Content Viewer is only for controls that genuinely cannot grow.
- Hide only decorative or duplicated content. Hiding a control, grouping away an action, or marking a view modal must not remove a route to functionality.
- Move assistive focus only for important context changes; otherwise post an announcement or layout change. Never auto-dismiss content an assistive technology is focused on.
- Support accessibility unconditionally. Use `isVoiceOverRunning` and similar flags to adapt behavior, never to decide whether elements get labels. Don't build an in-app screen reader with speech synthesis.
- Use `accessibilityIdentifier` for tests; never put test IDs in labels.
- Apple session sample code is not always valid in the SDK: `accessibilityAction(named:)` (not `accessibilityActions("…")`), `accessibilityDirectTouch(options:)` (not an array as the first argument), and `if` inside rotor builders requires an iOS 27 deployment target. See the [API catalog](references/api-catalog.md).

## Optional read-only audit

For a Swift/Objective-C project, use Python 3.10+ with no extra packages. Resolve `<skill-path>` from this installed `SKILL.md` directory:

```sh
python3 <skill-path>/scripts/audit_accessibility.py /path/to/project
python3 <skill-path>/scripts/audit_accessibility.py /path/to/project --json
```

The helper lists review candidates such as fixed font sizes, single-line limits, gesture-only interactions, unlabeled asset images or icon buttons, role words or test IDs in labels, hidden elements, hard-coded colors, repeating or parallax motion without a Reduce Motion check, and timed dismissal. It never edits files and doesn't parse Swift semantically; confirm each candidate in context before changing code.

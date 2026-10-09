# Apple Accessibility Skill

An agent skill for designing, implementing, reviewing, and testing accessibility in Apple-platform apps: SwiftUI, UIKit, AppKit, RealityKit, watchOS, tvOS, and visionOS.

Built from Apple's Accessibility framework documentation (a full crawl of about 2,000 public pages across Accessibility, SwiftUI, UIKit, AppKit, XCUIAutomation, MediaAccessibility, AVFAudio, and RealityKit), the Human Interface Guidelines, all nine App Store Connect Accessibility Nutrition Label criteria, and 60+ WWDC sessions and tech talks from WWDC18 through WWDC26. Every recommended API was cross-checked against the Xcode 27.1 SDKs. Research checked **October 9, 2026**. Inspired by [Apple Liquid Glass Skill](https://github.com/DanielJamesTronca/apple-liquid-glass-skill) and [Apple iPhone Duo Skill](https://github.com/DanielJamesTronca/apple-iphone-duo-skill).

## Install

Using the Skills CLI:

```sh
npx skills add DanielJamesTronca/apple-accessibility-skill -g
```

In Codex, ask:

```text
Use $skill-installer to install skills/apple-accessibility from
https://github.com/DanielJamesTronca/apple-accessibility-skill.
```

For manual installation, copy `skills/apple-accessibility` to `~/.agents/skills/apple-accessibility` for user-wide discovery, or `.agents/skills/apple-accessibility` in a project for repository-scoped discovery. Copy the entire folder, including references and scripts.

To browse it as a Codex plugin, register the repository marketplace:

```sh
codex plugin marketplace add DanielJamesTronca/apple-accessibility-skill
```

Then open the Plugins Directory in the ChatGPT desktop app, select **Apple Accessibility Skill**, and install **Apple Accessibility**. Marketplace registration and plugin installation are separate steps.

In Claude Code:

```text
/plugin marketplace add DanielJamesTronca/apple-accessibility-skill
/plugin install apple-accessibility@apple-accessibility-skill
```

The repo includes a portable `plugin.json`, Codex and Claude compatibility manifests, and marketplace catalogs. It's distributed through GitHub; inclusion in a public plugin directory is a separate submission. The skill is self-contained and needs no Apple login, local Xcode skill, Python package, or network access to read. Xcode is needed to build Apple-platform code; the optional audit helper uses Python 3.10+.

## Use

```text
Use $apple-accessibility to review this screen for VoiceOver and Dynamic Type.

Use $apple-accessibility to make this custom SwiftUI slider and canvas accessible
without changing the design or the iOS 17 deployment target.

Use $apple-accessibility to evaluate our iPhone and Apple TV apps for
Accessibility Nutrition Labels.
```

The examples above use Codex invocation syntax. In Claude Code, invoke the installed plugin skill as `/apple-accessibility:apple-accessibility`, followed by your request.

## Coverage

| Area | Included |
| --- | --- |
| Foundations | Element model, label writing, traits and values, grouping, order, focus, announcements, modals, representables |
| Custom controls | Adjustable actions, `accessibilityRepresentation`, custom actions, passthrough, direct touch, zoom, drag and drop, hover and gestures |
| Navigation and reading | Rotors, Mac containers, custom content, long-form text, text navigation, page turning, `UITextInput`, speech attributes, math |
| Dynamic Type | Text styles, custom fonts, reflow, scrolling, images, Large Content Viewer, tvOS 27 Large Text, watchOS, games |
| Visual settings | Contrast, Increase Contrast, Dark Mode, color, transparency, Liquid Glass, Smart Invert, Reduce Motion, flashing, animated images |
| Input alternatives | Voice Control, Switch Control, Full Keyboard Access, AssistiveTouch, Dwell, Pointer Control, targets, timing, Guided Access, kiosks |
| Cognitive | Design principles, Assistive Access scene and plist keys, Guided Access restrictions |
| Media and speech | Captions, iOS 27 generated subtitles and style preview, audio descriptions, Music Haptics, speech synthesis, Personal Voice, hearing devices |
| Charts and data | Swift Charts, audio graphs (`AXChart`), data tables, braille maps and translation |
| Platforms | macOS/Catalyst, watchOS, tvOS, visionOS and RealityKit, widgets, web content, Unity and native games |
| Testing | Test matrix, VoiceOver and Voice Control basics, Accessibility Inspector, audits in UI tests, iOS 27 VoiceOver automation |
| Nutrition Labels | Decision rule, all nine criteria, implementation latitude, App Store Connect steps |

Start with [SKILL.md](skills/apple-accessibility/SKILL.md); details load only when relevant. The [API catalog](skills/apple-accessibility/references/api-catalog.md) separates iOS 27, 26.x, 18, and 17 additions and lists corrections to Apple session sample code that doesn't compile against the current SDK. The [research ledger](skills/apple-accessibility/references/sources.md) documents coverage, conflicts, and limits.

## Read-only audit

```sh
python3 skills/apple-accessibility/scripts/audit_accessibility.py /path/to/app
python3 skills/apple-accessibility/scripts/audit_accessibility.py /path/to/app --json
```

Findings are review candidates, not proven bugs. The helper scans Swift and Objective-C without editing them; ignores comments, string contents, generated dependency folders, and symlinks; and reports file/line context. Rules cover fixed font sizes, single-line limits, gesture-only interactions, tap gestures without button semantics, unlabeled asset images and icon-only buttons, role words or test IDs in labels, hidden elements, hard-coded colors, repeating or parallax motion without a Reduce Motion check, timed dismissal, custom drawing without accessibility, `if` in rotor builders, invalid session APIs, and assistive-technology gating. It's a lexical aid, not a Swift parser.

## Validation

```sh
python3 -m unittest discover -s tests -v
python3 scripts/validate_package.py
./scripts/check_examples.sh  # macOS with Xcode 27.1 selected
```

Original examples are type-checked in Swift 6 for iOS 17 (with availability gates), Mac Catalyst 17, macOS 14 (AppKit), and an iOS 17 UI-test target. Compile checks don't verify spoken output, focus behavior, or rendered layout; those need assistive-technology testing in the consuming app. The [behavioral evaluation scenarios](tests/skill_evals.json) exercise the skill's decisions without asserting its wording.

## Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) for updating evidence and validation. Report SDK or OS behavior with the exact Xcode and OS build.

MIT licensed. Independent community skill; not affiliated with or endorsed by Apple. Linked Apple materials retain their own rights.

# Navigation efficiency and reading experiences

Sighted people skim by headings, icons, colors, and layout. VoiceOver users need equivalent shortcuts: headings, containers, rotors, custom content, and continuous reading.

## Rotors

The VoiceOver rotor (two-finger twist on iOS; VO-U on macOS) switches navigation units—headings, links, containers, lines, words, actions—then swipes up/down move by that unit. System rotors appear automatically for headers and containers. Add custom rotors where sighted people scan for a category: flagged mail, warnings, bookmarks, stores vs. parks on a map, alerts in a brochure. [VoiceOver efficiency with custom rotors](https://developer.apple.com/videos/play/wwdc2020/10116/).

SwiftUI:

- `.accessibilityRotor("Warnings") { ForEach(warnings) { AccessibilityRotorEntry($0.title, id: $0.id) } }`. Entries match elements by `ForEach` identity. Attach the rotor to a container: `List` and `LazyVStack` are containers already; add `.accessibilityElement(children: .contain)` to stacks.
- When the element isn't the `ForEach` root, tag it with `.accessibilityRotorEntry(id:in:)` and create entries with the same `Namespace`.
- `accessibilityRotor(_:textRanges:)` exposes ranges in a `TextEditor` (links, phone numbers, emails).
- `AccessibilitySystemRotor` replaces a system rotor (for example, `.headings`) with your own ordering.
- **Xcode 27 SDK caveat:** rotor content builders now use `ContentBuilder`. An `if` inside `ForEach` (as in Apple's WWDC21 and WWDC25 samples) depends on an `Optional` conformance introduced in iOS 27, so it fails to compile for iOS 26 or earlier deployment targets. Filter the collection instead (`ForEach(items.filter(\.isFlagged))`), which compiled for an iOS 17 target. Both behaviors verified with Xcode 27.1 (27A9269).

UIKit: set `accessibilityCustomRotors` to `UIAccessibilityCustomRotor(name:) { predicate in … }`. Read `predicate.currentItem` and `predicate.searchDirection`, return the next `UIAccessibilityCustomRotorItemResult(targetElement:targetRange:)`, or `nil` at either end. A text rotor's target must conform to `UITextInput` with a `UITextRange`. Include useful context in the label: "Apple, Union Square, 1.8 miles". AppKit uses `NSAccessibilityCustomRotor`.

## Data-rich elements: custom content

Reading every statistic in a cell overloads people; omitting it hides information. Keep the label short (name and kind), and move secondary details into custom content that people request through the More Content rotor (iOS) or VO-Command-Slash (macOS). [Tailor the VoiceOver experience in your data-rich apps](https://developer.apple.com/videos/play/wwdc2021/10121/).

- UIKit/AppKit: adopt `AXCustomContentProvider` and return `[AXCustomContent(label:value:)]` in the desired order. `importance = .high` always speaks that item (and keeps it in the rotor).
- SwiftUI: hide the source subviews, then add `.accessibilityCustomContent(.age, age, importance: .high)` with an `AccessibilityCustomContentKey` extension (`static var age: Self { Self("Age") }`). Keys let several views update the same entry. In the Xcode 27.1 SDK, a string-literal label combined with a `String` variable value is ambiguous (`LocalizedStringKey` vs. `LocalizedStringResource` overloads); use a key or `Text` values.
- People choose how "More content available" is signaled in VoiceOver Verbosity settings.

## macOS navigation is hierarchical

VoiceOver on macOS navigates by container: people move to a group, then interact into it (VO-Shift-Down). A dense pro UI with hundreds of controls becomes unusable without groups, and pointless nesting slows people down. Group functional regions—sidebar, toolbar, inspector, editor—and name each group. Mac Catalyst turns UIKit containers into nodes the same way, so container labels should include important state ("Coffee list, Ethiopia selected"). Add keyboard shortcuts for jumping to regions; Mac VoiceOver users rely on them more than iOS users do. See [platforms](platforms.md). [Accessibility design for Mac Catalyst](https://developer.apple.com/videos/play/wwdc2020/10117/), [Group Lab, 23:09](https://developer.apple.com/videos/play/wwdc2026/8005/?time=1389).

## Long-form text and reading apps

Reading is about moving fluidly through text, not jumping between controls. Goals: granular navigation (line, word, character), continuous read-all across pages, and complete text selection. Assistive technologies involved include VoiceOver, Speak Screen (two-finger swipe down from the top), Speak Selection, and Accessibility Reader (iOS 26+, launched from Control Center or a shortcut). [Enhance the accessibility of your reading app](https://developer.apple.com/videos/play/wwdc2026/219/).

1. **Use system text views.** `UITextView`, `NSTextView`, SwiftUI `TextEditor`, and `Text` with `.textSelection(.enabled)` adopt `UITextInput`-level accessibility: touch exploration by line, lines/words/characters rotors, and selection.
2. **Link separate text views.** If each paragraph is its own view, line navigation stops at the boundary. In UIKit set `accessibilityNextTextNavigationElement` and `accessibilityPreviousTextNavigationElement` (iOS 18; not on tvOS/watchOS). In SwiftUI, apply `.accessibilityLinkedGroup(id:in:)` with a shared id and namespace; the modifier dates to iOS 14, but the text-navigation behavior arrives in iOS 27. In AppKit use `accessibilitySharedTextUIElements`.
3. **Turn pages during read-all.** Add the `.causesPageTurn` trait to the last element on a page and implement `accessibilityScroll(_:)` to change pages and post `.pageScrolled` with "Page 3 of 12". Speak Screen and VoiceOver then advance automatically.
4. **Expose actions on selections.** Put selection-dependent commands (save quote, highlight, define) in the edit rotor with `UIAccessibilityCustomAction.editCategory` (iOS 18), appended to `super.accessibilityCustomActions`.
5. **Make custom-rendered text accessible.** For Core Text drawing, scanned pages, or handwriting, implement the full `UITextInput` protocol on the accessibility element: `text(in:)`, `selectionRects(for:)`, a tokenizer (subclass `UITextInputStringTokenizer`) for line/sentence/word/character units, and `inputDelegate` selection callbacks. Add `UITextInteraction(for: .nonEditable)` for visible selection handles. The older `UIAccessibilityReadingContent` protocol (line number for point, content and frame for a line, page content) still works and is simpler, but has lower fidelity. [Creating an Accessible Reading Experience](https://developer.apple.com/videos/play/wwdc2019/248/).

See [ReadingContent.swift](examples/ReadingContent.swift).

## Controlling how text is spoken

- Language: `accessibilitySpeechLanguage` attribute (UIKit `NSAttributedString` keys, SwiftUI `AttributedString` accessibility attributes) so VoiceOver picks a matching voice.
- Pronunciation: `accessibilitySpeechIPANotation`, `accessibilitySpeechSpellOut`, `accessibilitySpeechPunctuation`, and pitch. SwiftUI view modifiers: `speechSpellsOutCharacters`, `speechAlwaysIncludesPunctuation`, `speechAdjustedPitch`, `speechAnnouncementsQueued`.
- iOS 27 adds an `accessibilitySpeechSSML` attributed-string attribute (Foundation `AttributeScopes.AccessibilityAttributes`) for SSML-controlled speech. Confirm its exact behavior in the SDK before relying on it.
- Content type: `accessibilityTextContentType` (`.sourceCode`, `.narrative`, `.messaging`, `.spreadsheet`, `.wordProcessing`, `.console`, `.fileSystem`, `.plain`) tunes VoiceOver's reading. UIKit: `accessibilityTextualContext`.
- Headings: `accessibilityHeading(.h1…)` for document-like content; macOS 26 adds heading-level, language, and search keys in `NSAccessibility` for richer document navigation.
- Math: `AXMathExpressionProvider.accessibilityMathExpression()` returning `AXMathExpression` trees (iOS 18.2/macOS 15.2) lets VoiceOver and braille present equations structurally instead of as flattened text.
- Vertical text: honor `AccessibilitySettings.prefersHorizontalTextLayout` and its change notification for languages that support both directions.
- Custom text cursors: honor `AccessibilitySettings.prefersNonBlinkingTextInsertionIndicator` (iOS 18).

## Text input

Custom keyboards, PIN pads, and code-entry widgets must produce correct speech and braille output, editing, and selection for VoiceOver, and accept dictation and "Select …/Delete that" commands for Voice Control. Prefer standard text fields; mark key buttons with `.isKeyboardKey`. Use the correct `textContentType` so the system can help (one-time codes, passwords).

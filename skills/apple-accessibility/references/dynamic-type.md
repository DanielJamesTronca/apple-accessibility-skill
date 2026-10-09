# Dynamic Type and larger text

Text size is one of the most used accessibility settings. iOS offers seven standard sizes (Large is the default) and five more under Larger Accessibility Sizes. Body text is 17 pt at the default size, 28 pt at the first accessibility size, and 53 pt at the largest (about 310%). The standard sizes reach about 135%. The App Store's Larger Text label requires at least 200% or the system maximum. People can also change size per app from Control Center. [Prepare your app for Accessibility Nutrition Labels](https://developer.apple.com/videos/play/tech-talks/111433/), [Get started with Dynamic Type](https://developer.apple.com/videos/play/wwdc2024/10074/).

Platforms: iOS, iPadOS, watchOS (accessibility sizes since watchOS 8; the largest is more than 140%), visionOS, and **tvOS 27**, which adds system Large Text (Settings > Accessibility > Display > Text Size, Large through Accessibility XXXL) and the Larger Text label for tvOS. The Larger Text label isn't offered for Mac apps; still respect macOS text-size settings and offer in-app size controls for reading content. [Prepare your tvOS apps for Dynamic Type](https://developer.apple.com/videos/play/wwdc2026/221/).

## Make text scale

| Need | SwiftUI | UIKit |
| --- | --- | --- |
| System font | `.font(.body)`, `.title`, `.caption`… | `UIFont.preferredFont(forTextStyle:)` + `adjustsFontForContentSizeCategory = true` |
| Custom font | `.font(.custom("Name", size: 17, relativeTo: .body))`; `Font.custom(_:size:)` scales relative to `.body` by default | `UIFontMetrics(forTextStyle: .body).scaledFont(for: font)` + `adjustsFontForContentSizeCategory = true` |
| Non-scaling (rare, deliberate) | `Font.custom(_:fixedSize:)`, `.system(size:)` | `UIFont.systemFont(ofSize:)` without metrics |
| Scaled spacing/sizes | `@ScaledMetric(relativeTo: .body) var padding = 10` | `UIFontMetrics.default.scaledValue(for:)` |
| Unlimited lines | `.lineLimit(nil)` (default for `Text`) | `numberOfLines = 0` |
| Bold Text with custom fonts | `@Environment(\.legibilityWeight)` == `.bold` | `UIAccessibility.isBoldTextEnabled` / `traitCollection.legibilityWeight` |

- Choose the text style closest in size to the custom font; styles scale at different rates (captions grow proportionally more than titles), but relative hierarchy holds. HIG [Typography specifications](https://developer.apple.com/design/human-interface-guidelines/typography#Specifications) list every size per style and setting.
- SwiftUI doesn't synthesize bold or italic for custom fonts; ship the weights you use. Declare fonts with `UIAppFonts` (iOS, watchOS, tvOS, Catalyst) or `ATSApplicationFontsPath` (macOS). [Applying custom fonts to text](https://developer.apple.com/documentation/swiftui/applying-custom-fonts-to-text).
- Fixed font sizes and fixed frames are the two most common defects (`frame(width: 300)` truncates as text grows). Use `frame(maxWidth: .infinity)` and flexible constraints.
- Avoid Ultralight, Thin, and Light weights for UI text. Defaults and minimums: iOS 17/11 pt, macOS 13/10, tvOS 29/23, visionOS 17/12, watchOS 16/12. [HIG: Typography](https://developer.apple.com/design/human-interface-guidelines/typography).

## Adapt layout at accessibility sizes

- Wrap, don't truncate. Aim to show as much useful text at the largest accessibility size as at the largest standard size. Truncation is acceptable only when the full text is one tap away (detail view, expand control).
- Switch horizontal arrangements to vertical: `@Environment(\.dynamicTypeSize)` and `dynamicTypeSize.isAccessibilitySize` with `AnyLayout(HStackLayout())`/`AnyLayout(VStackLayout())`, or in UIKit `traitCollection.preferredContentSizeCategory.isAccessibilityCategory` plus `registerForTraitChanges([UITraitPreferredContentSizeCategory.self])` to update `UIStackView.axis`. Reduce column counts (for example a six-up shelf becomes four with `containerRelativeFrame(_:count:spacing:)`).
- Put everything that can grow in a `ScrollView`. Pin primary buttons with `safeAreaBar(edge: .bottom)` (iOS 26) or `safeAreaInset`, and use `scrollBounceBehavior(.basedOnSize)` so short content doesn't bounce. Applying `fixedSize` alone just pushes other content off screen.
- Prioritize content over chrome: repeated, predictable controls (Back, Edit, tab bars) may stay small while primary content and primary actions scale. Keep primary elements near the top. Control Center turns a 1×2 control into 1×4 at accessibility sizes, an example of designing alternate layouts with your designers. [HIG: Typography – Supporting Dynamic Type](https://developer.apple.com/design/human-interface-guidelines/typography#Supporting-Dynamic-Type).
- Test long localizations, right-to-left scripts, and scripts with tall ascenders, descenders, or diacritics that tight constraints clip.
- Use `dynamicTypeSize(...)` range limits only for small, non-essential ornaments, never on body content.

## Images and symbols

- SF Symbols scale with adjacent text automatically. In UIKit use `UIImage.SymbolConfiguration(textStyle:)` or `preferredSymbolConfiguration`. For text plus icon, prefer `Label` or text interpolation (`Text("\(Image(systemName: "leaf")) Garden")`), and let text wrap beneath the icon.
- Scale essential raster/PDF images with `@ScaledMetric` (or `adjustsImageSizeForAccessibilityContentSizeCategory`). Decorative icons (like Settings row icons) can stay fixed while text grows; rarely, remove purely decorative views at the largest sizes without losing function.

## Large Content Viewer

For controls that must stay small—tab bars, toolbars, custom bottom bars—people at accessibility text sizes long-press to see an enlarged label and icon, slide across items, and lift to activate. Standard UIKit and SwiftUI bars support it already; ensure bar images preserve vector data or set `largeContentSizeImage`. It's a fallback, never a substitute for scaling content. [Large Content Viewer – Ensuring Readability for Everyone](https://developer.apple.com/videos/play/wwdc2019/261/).

- SwiftUI: `.accessibilityShowsLargeContentViewer()` or `.accessibilityShowsLargeContentViewer { Label(title, systemImage: symbol) }`; read `accessibilityLargeContentViewerEnabled`.
- UIKit: set `showsLargeContentViewer`, `largeContentTitle`, `largeContentImage`, `scalesLargeContentImage` on each item view (UIView already conforms to `UILargeContentViewerItem`; `UIButton`/`UILabel` infer title and image), and add one `UILargeContentViewerInteraction` to the bar. The delegate can map points to items and handle activation. If an item has its own long press, lengthen that gesture's duration at accessibility sizes and allow simultaneous recognition with `gestureRecognizerForExclusionRelationship`.

## Games and engines

Unity games can read the preferred size through Apple's Unity Accessibility plug-in (`AccessibilitySettings.PreferredContentSizeMultiplier`, change events) and swap to large-print assets. Games that manage their own text must offer an equivalent in-app size control. Scale the smallest text as much as possible while keeping hierarchy; dialogue matters more than transient hit numbers. [Add accessibility to your Unity games](https://developer.apple.com/videos/play/wwdc2022/10151/).

## Verify

- Xcode Previews: the Variants control → Dynamic Type Variants renders every size; or `#Preview` with `.environment(\.dynamicTypeSize, .accessibility5)`.
- Xcode debugger Environment Overrides and the Xcode 27 simulator controls switch size, contrast, and appearance while running.
- `performAccessibilityAudit(for: [.dynamicType, .textClipped])` in UI tests on iOS, tvOS, and watchOS.
- On device, test each common task at AX1, AX3, and AX5 (the largest), in both orientations and with a long localization.

See [AdaptiveAppearance.swift](examples/AdaptiveAppearance.swift).

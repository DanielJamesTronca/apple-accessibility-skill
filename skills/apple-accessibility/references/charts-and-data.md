# Charts, data visualizations, and tables

A chart is useless if you can't see it, unless it's exposed in three layers: a visual design that doesn't rely on color, navigable data points, and a summary or audio graph that conveys shape and trend. [Bring accessibility to charts in your app](https://developer.apple.com/videos/play/wwdc2021/10122/).

## Visual accessibility

- Use contrast of at least 4.5:1 for text and lines against the background.
- Avoid red/green and blue/yellow pairings. Distinguish series with symbols, line styles, or direct labels, not color alone. In Swift Charts, `.symbol(by: .value("Series", …))` alongside `.foregroundStyle(by:)`.
- Order legend entries the same way as the series, or label series directly on the chart.
- If the default design can't include symbols, add them when Differentiate Without Color is on, raise contrast with Increase Contrast, and drop transparency with Reduce Transparency.
- Offer alternate palettes or customization for color-coded content (heat maps, teams).

## Swift Charts

Swift Charts creates accessibility elements for marks and provides VoiceOver navigation and audio graphs automatically. [Hello Swift Charts](https://developer.apple.com/videos/play/wwdc2022/10136/). Refine them:

- `.accessibilityLabel` and `.accessibilityValue` on marks to speak domain values with units ("March, 268 births per 10,000").
- `.accessibilityHidden(true)` on decorative marks (rule marks used as gridlines).
- `.accessibilityChartDescriptor(_:)` to replace the automatic descriptor with a curated one (summary, axis formatting).
- Group dense data into meaningful intervals instead of exposing thousands of points.

## Custom-drawn charts

SwiftUI `Canvas`, Core Graphics, Metal, or third-party drawing need explicit accessibility:

1. Make the chart a container with a label (its title). UIKit: `accessibilityContainerType = .semanticGroup` and `accessibilityLabel`. SwiftUI: `.accessibilityElement(children: .contain)` or a labeled `Canvas` with `.accessibilityChildren { … }`.
2. Expose one element per data point or interval with a localized, pluralized value and a frame. UIKit: `UIAccessibilityElement(accessibilityContainer: chartView)` with `accessibilityValue` and `accessibilityFrameInContainerSpace`, returned from `accessibilityElements`.
3. Use intervals for large datasets, both for navigation and performance.
4. Conform to `AXChart` and return an `AXChartDescriptor` from `accessibilityChartDescriptor` to enable **audio graphs**: VoiceOver plays the series as pitch over time, supports interactive scrubbing that speaks values, and presents statistical summaries (trend, outliers). Find it in the VoiceOver rotor under Audio Graph → Chart Details.

`AXChartDescriptor(title:summary:xAxis:yAxis:additionalAxes:series:)`:

- **Axes:** `AXNumericDataAxisDescriptor(title:range:gridlinePositions:valueDescriptionProvider:)`. Grid lines become haptics during playback. The value provider formats spoken values ("5 cups"). Use `AXCategoricalDataAxisDescriptor(title:categoryOrder:)` for categories.
- **Series:** `AXDataSeriesDescriptor(name:isContinuous:dataPoints:)`. `isContinuous` is `true` for lines and `false` for bars or scatter points. Data points are `AXDataPoint(x:y:)`, with optional additional values and labels.
- **Summary:** one or two sentences with the key insight—the chart's alt text.
- **SwiftUI:** `.accessibilityChartDescriptor(_:)` with a type conforming to `AXChartDescriptorRepresentable`.
- **Live data:** `AXLiveAudioGraph` (iOS 15) can sonify a value that updates in real time.

See [AudioGraph.swift](examples/AudioGraph.swift).

## Tables and grids

- Data tables: UIKit `UIAccessibilityContainerDataTable` (with `UIAccessibilityContainerDataTableCell`) exposes row and column structure, headers, and spans so VoiceOver can announce "Row 3, Column 2". Set `accessibilityContainerType = .dataTable`.
- SwiftUI `Table` and `Grid` provide structure for standard content; label header cells and avoid purely visual alignment hacks.
- For cells dense with statistics, use custom content rather than a long label (see [navigation and reading](navigation-and-reading.md#data-rich-elements-custom-content)).

## Braille

VoiceOver drives refreshable braille displays automatically from your labels and text. Additional APIs:

- `AXBrailleMap` and `AXBrailleMapRenderer` (iOS 15.2) render images, icons, or charts as raised dots on two-dimensional braille displays.
- `AXBrailleTranslator` and `AXBrailleTable` (iOS/macOS/visionOS 26) translate print text to braille and back with a chosen table, for apps that build braille features.
- Hardware makers: Apple publishes HID references for braille displays and for brain-computer interfaces (iOS/visionOS 26). [Braille displays](https://developer.apple.com/documentation/accessibility/braille-displays).

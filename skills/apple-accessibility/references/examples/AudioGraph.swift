// Original examples for the apple-accessibility skill. Type-checked with Swift 6 for iOS 17+.
import Accessibility
import Charts
import SwiftUI

struct VisitSample: Identifiable {
    let id = UUID()
    let month: Int
    let visitors: Double
    let place: String
}

// MARK: Swift Charts: distinguish series by symbol, not only color.

struct VisitorsChart: View {
    let samples: [VisitSample]

    var body: some View {
        Chart(samples) { sample in
            LineMark(x: .value("Month", sample.month), y: .value("Visitors", sample.visitors))
                .foregroundStyle(by: .value("Place", sample.place))
            PointMark(x: .value("Month", sample.month), y: .value("Visitors", sample.visitors))
                .foregroundStyle(by: .value("Place", sample.place))
                .symbol(by: .value("Place", sample.place))
                .accessibilityLabel("\(sample.place), month \(sample.month)")
                .accessibilityValue("\(Int(sample.visitors)) visitors")
        }
        .accessibilityChartDescriptor(VisitorsDescriptor(samples: samples))
    }
}

// MARK: A curated descriptor: summary, formatted axes, one series per place.

struct VisitorsDescriptor: AXChartDescriptorRepresentable {
    let samples: [VisitSample]

    func makeChartDescriptor() -> AXChartDescriptor {
        let months = samples.map { Double($0.month) }
        let counts = samples.map(\.visitors)
        let xAxis = AXNumericDataAxisDescriptor(
            title: "Month",
            range: (months.min() ?? 1)...(months.max() ?? 12),
            gridlinePositions: []
        ) { value in "Month \(Int(value))" }
        let yAxis = AXNumericDataAxisDescriptor(
            title: "Visitors",
            range: 0...(counts.max() ?? 1),
            gridlinePositions: [] // Grid lines become haptics during audio graph playback.
        ) { value in "\(Int(value)) visitors" }

        let series = Dictionary(grouping: samples, by: \.place)
            .sorted { $0.key < $1.key }
            .map { place, values in
                AXDataSeriesDescriptor(
                    name: place,
                    isContinuous: true, // Drawn as a line.
                    dataPoints: values.map { AXDataPoint(x: Double($0.month), y: $0.visitors) }
                )
            }

        return AXChartDescriptor(
            title: "Monthly visitors",
            summary: "Visits peak in July at every location, then fall through December.",
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: series
        )
    }
}

#if canImport(UIKit)
import UIKit

// MARK: A custom-drawn UIKit chart: container, point elements, and AXChart.

final class SparklineView: UIView, @preconcurrency AXChart { // Nonisolated protocol requirements on a main-actor view.
    var points: [Double] = [] { didSet { setNeedsDisplay() } }
    var title = "Heart rate"

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityContainerType = .semanticGroup
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override var accessibilityLabel: String? {
        get { title }
        set { }
    }

    override var accessibilityElements: [Any]? {
        get {
            guard !points.isEmpty else { return [] }
            let width = bounds.width / CGFloat(points.count)
            return points.enumerated().map { index, value in
                let element = UIAccessibilityElement(accessibilityContainer: self)
                element.accessibilityLabel = "Reading \(index + 1)"
                element.accessibilityValue = "\(Int(value)) beats per minute"
                element.accessibilityFrameInContainerSpace = CGRect(x: CGFloat(index) * width, y: 0,
                                                                    width: width, height: bounds.height)
                return element
            }
        }
        set { }
    }

    var accessibilityChartDescriptor: AXChartDescriptor? {
        get {
            let yAxis = AXNumericDataAxisDescriptor(title: "Beats per minute",
                                                    range: 0...(points.max() ?? 1),
                                                    gridlinePositions: []) { "\(Int($0)) BPM" }
            let xAxis = AXNumericDataAxisDescriptor(title: "Reading",
                                                    range: 1...Double(max(points.count, 1)),
                                                    gridlinePositions: []) { "Reading \(Int($0))" }
            let series = AXDataSeriesDescriptor(
                name: title, isContinuous: true,
                dataPoints: points.enumerated().map { AXDataPoint(x: Double($0.offset + 1), y: $0.element) }
            )
            return AXChartDescriptor(title: title, summary: nil, xAxis: xAxis, yAxis: yAxis,
                                     additionalAxes: [], series: [series])
        }
        set { }
    }
}
#endif

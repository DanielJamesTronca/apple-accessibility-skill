// Original examples for the apple-accessibility skill. Type-checked with Swift 6 for iOS 17+ and Mac Catalyst 17+.
import UIKit

// MARK: Group title/value pairs into single elements.

final class StatsView: UIView {
    private let pairs: [(title: UILabel, value: UILabel)]
    private var cachedElements: [UIAccessibilityElement]?

    init(pairs: [(title: UILabel, value: UILabel)]) {
        self.pairs = pairs
        super.init(frame: .zero)
        for pair in pairs { addSubview(pair.title); addSubview(pair.value) }
        accessibilityContainerType = .semanticGroup
        accessibilityLabel = String(localized: "Details")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    /// Call when the model changes so elements are rebuilt.
    func invalidateAccessibility() { cachedElements = nil }

    override var accessibilityElements: [Any]? {
        get {
            if let cachedElements { return cachedElements }
            let elements = pairs.map { pair in
                let element = UIAccessibilityElement(accessibilityContainer: self)
                element.accessibilityLabel = pair.title.text
                element.accessibilityValue = pair.value.text
                element.accessibilityFrameInContainerSpace = pair.title.frame.union(pair.value.frame)
                return element
            }
            cachedElements = elements
            return elements
        }
        set { }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateAccessibility() // Frames change with layout and Dynamic Type.
    }
}

// MARK: Carousel exposed as one adjustable element; its buttons stay reachable.

final class CarouselAccessibilityElement: UIAccessibilityElement {
    var titles: [String] = []
    var index = 0
    var onChange: ((Int) -> Void)?

    override var accessibilityTraits: UIAccessibilityTraits {
        get { .adjustable }
        set { }
    }
    override var accessibilityLabel: String? {
        get { String(localized: "Dog picker") }
        set { }
    }
    override var accessibilityValue: String? {
        get { titles.indices.contains(index) ? titles[index] : nil }
        set { }
    }
    override func accessibilityIncrement() { move(by: 1) }
    override func accessibilityDecrement() { move(by: -1) }

    private func move(by delta: Int) {
        let next = index + delta
        guard titles.indices.contains(next) else { return }
        index = next
        onChange?(next)
    }
}

final class CarouselContainerView: UIView {
    let collectionView: UICollectionView
    let favoriteButton = UIButton(type: .system)
    private lazy var carouselElement: CarouselAccessibilityElement = {
        let element = CarouselAccessibilityElement(accessibilityContainer: self)
        element.onChange = { [weak self] index in
            guard let self else { return }
            self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            // Content below the carousel changed; let VoiceOver re-read the screen.
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
        return element
    }()

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init(frame: .zero)
        addSubview(collectionView)
        addSubview(favoriteButton)
        favoriteButton.accessibilityLabel = String(localized: "Favorite")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override var accessibilityElements: [Any]? {
        get {
            carouselElement.accessibilityFrameInContainerSpace = collectionView.frame
            return [carouselElement, favoriteButton]
        }
        set { }
    }
}

// MARK: Context menu and swipe actions as custom actions with images.

final class ShelterInfoView: UIView {
    var shelterName = "" { didSet { accessibilityLabel = shelterName } }
    var call: () -> Void = { }
    var openMap: () -> Void = { }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true
        accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: String(localized: "Call"),
                                        image: UIImage(systemName: "phone")) { [weak self] _ in
                self?.call(); return true
            },
            UIAccessibilityCustomAction(name: String(localized: "Open Address in Maps"),
                                        image: UIImage(systemName: "map")) { [weak self] _ in
                self?.openMap(); return true
            },
        ]
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
}

// MARK: Custom overlay that behaves as a modal for assistive technologies.

final class GalleryOverlayView: UIView {
    var dismissHandler: () -> Void = { }

    override var accessibilityViewIsModal: Bool {
        get { true }
        set { }
    }

    override func accessibilityPerformEscape() -> Bool {
        dismissHandler()
        return true
    }

    func present(in parent: UIView) {
        parent.addSubview(self)
        UIAccessibility.post(notification: .screenChanged, argument: self)
    }
}

// MARK: Custom rotor that jumps between flagged annotations.

@MainActor func makeRotor(named name: String, items: @escaping () -> [UIView]) -> UIAccessibilityCustomRotor {
    UIAccessibilityCustomRotor(name: name) { predicate in
        let candidates = items()
        let current = predicate.currentItem.targetElement as? UIView
        let currentIndex = current.flatMap { view in candidates.firstIndex { $0 === view } }
        let target: Int
        switch predicate.searchDirection {
        case .previous: target = (currentIndex ?? candidates.count) - 1
        case .next: target = (currentIndex ?? -1) + 1
        @unknown default: return nil
        }
        guard candidates.indices.contains(target) else { return nil } // Boundary reached.
        return UIAccessibilityCustomRotorItemResult(targetElement: candidates[target], targetRange: nil)
    }
}

// MARK: Dynamic Type, Large Content Viewer, and trait-driven layout in UIKit.

final class ProfileHeaderView: UIView {
    private let nameLabel = UILabel()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let base = UIFont(name: "AvenirNext-DemiBold", size: 22) ?? .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: base)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 0
        nameLabel.accessibilityTraits.insert(.header)
        stack.addArrangedSubview(nameLabel)
        addSubview(stack)
        updateAxis()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (view: ProfileHeaderView, _: UITraitCollection) in
            view.updateAxis()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    private func updateAxis() {
        stack.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
    }
}

final class CompactToolbar: UIView {
    init(items: [(title: String, symbol: String)]) {
        super.init(frame: .zero)
        for item in items {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: item.symbol), for: .normal)
            button.accessibilityLabel = item.title
            button.showsLargeContentViewer = true      // These icons can't grow with text.
            button.largeContentTitle = item.title
            button.scalesLargeContentImage = true
            addSubview(button)
        }
        addInteraction(UILargeContentViewerInteraction())
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
}

// MARK: Announcements with priority, and settings observation.

@MainActor func announce(_ message: String, priority: UIAccessibilityPriority = .default) {
    let text = NSAttributedString(string: message,
                                  attributes: [.accessibilitySpeechAnnouncementPriority: priority])
    UIAccessibility.post(notification: .announcement, argument: text)
}

final class MotionAwareView: UIView {
    private var parallax: UIMotionEffectGroup?

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateMotion()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMotion),
                                               name: UIAccessibility.reduceMotionStatusDidChangeNotification,
                                               object: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    @objc private func updateMotion() {
        if UIAccessibility.isReduceMotionEnabled {
            if let parallax { removeMotionEffect(parallax) }
            parallax = nil
        } else if parallax == nil {
            let x = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
            x.minimumRelativeValue = -10
            x.maximumRelativeValue = 10
            let group = UIMotionEffectGroup()
            group.motionEffects = [x]
            addMotionEffect(group)
            parallax = group
        }
    }
}

// MARK: Informational element for VoiceOver that keyboard and switch cursors skip.

@MainActor func configureCaption(_ label: UILabel) {
    label.isAccessibilityElement = true
    label.accessibilityRespondsToUserInteraction = false
}

// MARK: Voice Control and Full Keyboard Access synonyms.

@MainActor func configureSettingsButton(_ button: UIButton) {
    button.accessibilityLabel = String(localized: "Settings")
    button.accessibilityUserInputLabels = [
        String(localized: "Settings"), String(localized: "Preferences"), String(localized: "Gear"),
    ]
}

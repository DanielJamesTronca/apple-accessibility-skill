// Original examples for the apple-accessibility skill. Type-checked with Swift 6 for iOS 17+ and Mac Catalyst 17+.
import SwiftUI
import UIKit

// MARK: Paginated reader built from one UITextView per paragraph.

final class ParagraphView: UITextView {
    var saveSelection: (String) -> Void = { _ in }

    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            let save = UIAccessibilityCustomAction(name: String(localized: "Save Quote")) { [weak self] _ in
                guard let self, let range = self.selectedTextRange, let text = self.text(in: range), !text.isEmpty else {
                    return false
                }
                self.saveSelection(text)
                return true
            }
            if #available(iOS 18.0, *) {
                save.category = UIAccessibilityCustomAction.editCategory // Appears in VoiceOver's edit rotor.
            }
            return (super.accessibilityCustomActions ?? []) + [save]
        }
        set { super.accessibilityCustomActions = newValue }
    }
}

final class ReaderPageViewController: UIViewController {
    var paragraphs: [ParagraphView] = []
    var currentPage = 1
    var pageCount = 1
    var turnPage: (UIAccessibilityScrollDirection) -> Bool = { _ in false }

    override func viewDidLoad() {
        super.viewDidLoad()
        linkParagraphs()
        // Speak Screen and VoiceOver read-all continue onto the next page after this element.
        paragraphs.last?.accessibilityTraits.insert(.causesPageTurn)
    }

    private func linkParagraphs() {
        guard #available(iOS 18.0, *) else { return }
        for (index, paragraph) in paragraphs.enumerated() {
            if index > 0 { paragraph.accessibilityPreviousTextNavigationElement = paragraphs[index - 1] }
            if index + 1 < paragraphs.count { paragraph.accessibilityNextTextNavigationElement = paragraphs[index + 1] }
        }
    }

    override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        guard turnPage(direction) else { return false }
        let status = String(localized: "Page \(currentPage) of \(pageCount)")
        UIAccessibility.post(notification: .pageScrolled, argument: status)
        return true
    }
}

// MARK: SwiftUI paragraphs linked for line-by-line navigation (behavior new in iOS 27).

struct PageView: View {
    @Namespace private var page
    let pageNumber: Int
    let paragraphs: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(paragraphs.indices, id: \.self) { index in
                Text(paragraphs[index])
                    .font(.body)
                    .textSelection(.enabled)
                    .accessibilityLinkedGroup(id: pageNumber, in: page)
            }
        }
        .accessibilityTextContentType(.narrative)
    }
}

// MARK: Lower-fidelity alternative for drawn text: UIAccessibilityReadingContent.

final class DrawnPageView: UIView, UIAccessibilityReadingContent {
    /// Lines in reading order with frames in this view's coordinates.
    var lines: [(text: String, frame: CGRect)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true
        accessibilityTraits = [.staticText, .causesPageTurn]
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func accessibilityLineNumber(for point: CGPoint) -> Int {
        // The documentation describes `point` in screen coordinates; convert before comparing to local frames.
        let screenSpace = window?.windowScene?.screen.coordinateSpace
        let local = screenSpace.map { convert(point, from: $0) } ?? point
        return lines.firstIndex { $0.frame.contains(local) } ?? NSNotFound
    }

    func accessibilityContent(forLineNumber lineNumber: Int) -> String? {
        lines.indices.contains(lineNumber) ? lines[lineNumber].text : nil
    }

    func accessibilityFrame(forLineNumber lineNumber: Int) -> CGRect {
        guard lines.indices.contains(lineNumber) else { return .zero }
        return UIAccessibility.convertToScreenCoordinates(lines[lineNumber].frame, in: self)
    }

    func accessibilityPageContent() -> String? {
        lines.map(\.text).joined(separator: "\n")
    }

    // For full line/word/character navigation and selection, implement UITextInput instead.
}

// MARK: Pronunciation and language hints.

func spokenTitle() -> NSAttributedString {
    NSAttributedString(string: "Arc de Triomphe", attributes: [.accessibilitySpeechLanguage: "fr-FR"])
}

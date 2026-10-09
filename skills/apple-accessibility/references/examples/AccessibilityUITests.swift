// Original examples for the apple-accessibility skill. Type-checked with Swift 6 for iOS 17+ UI-test targets.
import XCTest

final class AccessibilityAuditTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = true // Report every audit issue, not just the first.
        app = await XCUIApplication()
        await app.launch()
    }

    @MainActor func testHomeScreenAudit() throws {
        try app.performAccessibilityAudit()
    }

    @MainActor func testCheckoutAuditIgnoringReviewedIssue() throws {
        app.buttons["checkout"].tap() // Navigate by identifier; labels are for people.
        try app.performAccessibilityAudit(for: [.contrast, .dynamicType, .textClipped,
                                                .sufficientElementDescription, .hitRegion]) { issue in
            // Return true only for issues a person reviewed and documented as false positives.
            issue.auditType == .contrast && issue.element?.identifier == "brandLogo"
        }
    }

    @MainActor func testVoiceOverReadsHeadingFirst() throws {
        guard #available(iOS 27.0, *) else { throw XCTSkip("VoiceOver automation requires iOS 27.") }
        let voiceOver = XCUIDevice.shared.voiceOverService
        try voiceOver.enable()
        defer { try? voiceOver.disable() }
        app.activate()
        let first = try voiceOver.moveForward()
        XCTAssertEqual(first.utterance, "Library, heading")
        // Smoke-test that nothing in the first screens is silent.
        for _ in 0..<10 {
            XCTAssertFalse(try voiceOver.moveForward().utterance.isEmpty)
        }
    }
}

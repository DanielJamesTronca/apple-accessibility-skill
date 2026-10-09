"""CLI boundary tests: findings are candidates, preserve location, never mutate input."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "skills/apple-accessibility/scripts/audit_accessibility.py"


class AuditCLI(unittest.TestCase):
    def run_audit(self, root, *options):
        return subprocess.run([sys.executable, str(SCRIPT), str(root), *options],
                              capture_output=True, text=True, check=False)

    def report(self, files):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, text in files.items():
                (root / name).write_text(text)
            result = self.run_audit(root, "--json")
            self.assertEqual(result.returncode, 0, result.stderr)
            return json.loads(result.stdout)

    def rules(self, report):
        return {(item["rule"], item["path"], item["line"]) for item in report["candidates"]}

    def test_mixed_project_locations_and_read_only_behavior(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "View.swift").write_text('Text("Title")\n  .font(.system(size: 28))\nText("x").lineLimit(1)\n')
            (root / "Legacy.m").write_text("label.font = [UIFont systemFontOfSize:12];\n")
            (root / "Info.plist").write_text("<key>UIRequiresFullScreen</key><true/>\n")
            before = {p.name: hashlib.sha256(p.read_bytes()).digest() for p in root.iterdir()}
            result = self.run_audit(root, "--json")
            self.assertEqual(result.returncode, 0, result.stderr)
            report = json.loads(result.stdout)
            self.assertEqual(report["files_scanned"], 2)
            self.assertEqual(self.rules(report), {("fixed-font-size", "View.swift", 2),
                                                  ("single-line-limit", "View.swift", 3),
                                                  ("fixed-font-size", "Legacy.m", 1)})
            self.assertEqual(before, {p.name: hashlib.sha256(p.read_bytes()).digest() for p in root.iterdir()})

    def test_comment_and_string_examples_do_not_become_findings(self):
        report = self.report({"Demo.swift": '''// Image("hero") .lineLimit(1)
/* outer /* .accessibilityHidden(true) */ Color(red: 1, green: 0, blue: 0) */
let text = "Image(\\"inString\\") .lineLimit(1)"
let note = """
.system(size: 12) DragGesture()
"""
let gated = UIAccessibility.isVoiceOverRunning
'''})
        self.assertEqual([(item["rule"], item["line"]) for item in report["candidates"]],
                         [("assistive-technology-gate", 7)])

    def test_semantic_label_problems_use_the_literal_text(self):
        report = self.report({"Labels.swift": '''Text("a").accessibilityLabel("Play button")
Text("b").accessibilityLabel("QUOTE_TEXTVIEW")
Text("c").accessibilityLabel("Play")
'''})
        self.assertEqual(self.rules(report), {("label-includes-role", "Labels.swift", 1),
                                              ("label-looks-like-identifier", "Labels.swift", 2)})

    def test_images_and_icon_buttons_need_labels_unless_described_nearby(self):
        gap = "\n" * 6
        source = gap.join([
            'Image("hero")',
            'Image("described")\n    .accessibilityLabel("A lighthouse at dusk")',
            'Image(decorative: "texture")',
            'Button { } label: {\n    Image(systemName: "plus")\n}',
            'Button { } label: {\n    Image(systemName: "trash")\n}\n.accessibilityLabel("Delete draft")',
            'Button("Share", systemImage: "square.and.arrow.up") { }',
        ]) + "\n"
        report = self.report({"Images.swift": source})
        lines = source.splitlines()
        self.assertEqual(self.rules(report), {("unlabeled-image", "Images.swift", lines.index('Image("hero")') + 1),
                                              ("icon-only-button", "Images.swift",
                                               lines.index('    Image(systemName: "plus")') + 1)})

    def test_gestures_require_actions_and_taps_require_traits(self):
        report = self.report({"Gestures.swift": '''Rectangle()
    .gesture(DragGesture())







Rectangle()
    .gesture(DragGesture())
    .accessibilityAdjustableAction { _ in }






Text("Learn more")
    .onTapGesture { }







Text("Open")
    .onTapGesture { }
    .accessibilityAddTraits(.isButton)
'''})
        self.assertEqual(self.rules(report), {("gesture-only-interaction", "Gestures.swift", 2),
                                              ("tap-gesture-without-trait", "Gestures.swift", 20)})

    def test_motion_is_reported_only_without_a_reduce_motion_check(self):
        motion = "Circle().animation(.linear.repeatForever(), value: on)\n"
        unguarded = self.report({"Spinner.swift": motion})
        guarded = self.report({"Spinner.swift": "@Environment(\\.accessibilityReduceMotion) var reduceMotion\n" + motion})
        self.assertEqual(self.rules(unguarded), {("motion-without-reduce-motion", "Spinner.swift", 1)})
        self.assertEqual(guarded["candidates"], [])

    def test_rotor_if_session_api_and_timed_dismissal(self):
        report = self.report({"Mixed.swift": '''.accessibilityRotor("Warnings") {
    ForEach(items) { item in
        if item.isWarning {
            AccessibilityRotorEntry(item.title, id: item.id)
        }
    }
}
.accessibilityActions("Move Up") { }
.accessibilityDirectTouch([.requiresActivation])
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    isPresented = false
}
'''})
        self.assertEqual(self.rules(report), {("rotor-builder-if", "Mixed.swift", 3),
                                              ("invalid-session-api", "Mixed.swift", 8),
                                              ("invalid-session-api", "Mixed.swift", 9),
                                              ("timed-dismissal", "Mixed.swift", 10)})

    def test_custom_drawing_flags_only_files_without_any_accessibility(self):
        bare = self.report({"Board.swift": "final class Board: UIView {\n    override func draw(_ rect: CGRect) { }\n}\n"})
        covered = self.report({"Board.swift": "final class Board: UIView {\n    override func draw(_ rect: CGRect) { }\n"
                                              "    override var accessibilityElements: [Any]? { get { [] } set { } }\n}\n"})
        self.assertEqual(self.rules(bare), {("custom-drawing-without-accessibility", "Board.swift", 2)})
        self.assertEqual(covered["candidates"], [])

    def test_generated_dependencies_and_symlinks_are_not_scanned(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "Actual.swift").write_text('Text("x").lineLimit(1)\n')
            for name in ["Pods", "DerivedData", ".build"]:
                (root / name).mkdir()
                (root / name / "Generated.swift").write_text('Text("x").lineLimit(1)\n')
            (root / "link.swift").symlink_to(root / "Actual.swift")
            (root / "loop").symlink_to(root, target_is_directory=True)
            result = self.run_audit(root, "--json")
            self.assertEqual(result.returncode, 0, result.stderr)
            report = json.loads(result.stdout)
            self.assertEqual(report["files_scanned"], 1)
            self.assertEqual(len(report["candidates"]), 1)

    def test_single_file_and_human_output_do_not_fail_for_candidates(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "View.swift"
            source.write_text('Text("x").lineLimit(1)\n')
            result = self.run_audit(source)
            self.assertEqual(result.returncode, 0)
            self.assertIn("View.swift:1:", result.stdout)
            self.assertIn("not proven bugs", result.stdout)

    def test_invalid_or_unreadable_inputs_are_not_reported_as_clean(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            missing = self.run_audit(root / "missing")
            self.assertEqual(missing.returncode, 2)
            self.assertIn("does not exist", missing.stderr)
            (root / "Broken.swift").write_bytes(b"\xff\xfe")
            result = self.run_audit(root, "--json")
            self.assertEqual(result.returncode, 1)
            report = json.loads(result.stdout)
            self.assertTrue(report["warnings"])
            self.assertEqual(report["files_scanned"], 0)


if __name__ == "__main__":
    unittest.main()

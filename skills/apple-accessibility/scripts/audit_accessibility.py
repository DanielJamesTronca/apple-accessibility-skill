#!/usr/bin/env python3
"""Read-only lexical candidates for a contextual Apple-platform accessibility review."""
import argparse
import bisect
import json
import os
from pathlib import Path
import re

SUFFIXES = {".swift", ".m", ".mm", ".h"}
SKIP_DIRS = {".git", ".build", ".swiftpm", "DerivedData", "Pods", "Carthage", "node_modules", "build"}

ACCESSIBILITY_NEARBY = re.compile(
    r"accessibility(?:Label|Hidden|Element|Representation|Action|Actions|AdjustableAction|ZoomAction|"
    r"CustomActions|DragPoint|DropPoint|AddTraits|Increment|Decrement|UserInputLabels|InputLabels)"
    r"|UIAccessibilityCustomAction|isAccessibilityElement|Image\s*\(\s*decorative")
ACTION_NEARBY = re.compile(
    r"accessibility(?:Representation|Action|Actions|AdjustableAction|ZoomAction|CustomActions|DragPoint|DropPoint|"
    r"Increment|Decrement|Activate|DragSourceDescriptors|DropPointDescriptors)\b|UIAccessibilityCustomAction|"
    r"accessibilityElement\s*\(\s*\)")

# (rule, pattern, guidance, suppress_if_nearby, window)
LINE_RULES = (
    ("fixed-font-size",
     r"\.system\s*\(\s*size\s*:|UIFont\s*\.\s*(?:systemFont|boldSystemFont|italicSystemFont|monospacedSystemFont|"
     r"monospacedDigitSystemFont)\s*\(\s*ofSize|UIFont\s*\(\s*name\s*:|NSFont\s*\.\s*systemFont\s*\(\s*ofSize|"
     r"Font\s*\.\s*custom\s*\([^)]*fixedSize|\bsystemFontOfSize:|\bfontWithName:",
     "Text must scale: use text styles, Font.custom(_:size:relativeTo:), or UIFontMetrics. Fixed sizes can be valid for non-text glyphs.",
     re.compile(r"UIFontMetrics|scaledFont|scaledValue|relativeTo\s*:"), 2),
    ("single-line-limit",
     r"\.lineLimit\s*\(\s*1\s*\)|\bnumberOfLines\s*=\s*1\b",
     "Essential text should wrap at large sizes; truncate only when the full text is one tap away.",
     None, 0),
    ("gesture-only-interaction",
     r"\.onLongPressGesture\b|\bLongPressGesture\s*\(|\bDragGesture\s*\(|\bMagnifyGesture\s*\(|\bMagnificationGesture\s*\(|"
     r"\bRotateGesture\s*\(|\bRotationGesture\s*\(|\.onTapGesture\s*\(\s*count\s*:\s*[2-9]|"
     r"\bUI(?:Swipe|LongPress|Pinch|Pan|Rotation|ScreenEdgePan)GestureRecognizer\s*\(",
     "Gestures need an accessible alternative: a custom action, adjustable or zoom action, button, or menu item.",
     ACTION_NEARBY, 6),
    ("tap-gesture-without-trait",
     r"\.onTapGesture\s*(?:\{|\(\s*(?:perform|count\s*:\s*1)\b)",
     "A tappable non-button view needs the button trait or an action; prefer a real Button.",
     re.compile(r"isButton|\.button\b|accessibilityAction|accessibilityAdjustableAction|"
                r"accessibilityRepresentation|accessibilityHidden|accessibilityElement\s*\(\s*\)"), 5),
    ("hidden-from-accessibility",
     r"\.accessibilityHidden\s*\(\s*true\s*\)|\bisAccessibilityElement\s*=\s*false\b|\baccessibilityElementsHidden\s*=\s*true\b",
     "Hide only decorative or duplicated content; confirm no meaningful or interactive element disappears.",
     None, 0),
    ("hard-coded-color",
     r"\bColor\s*\(\s*red\s*:|\bUIColor\s*\(\s*red\s*:|\bNSColor\s*\(\s*(?:calibrated|device|srgb)?[Rr]ed\s*:|"
     r"#colorLiteral|\b(?:UI|NS)?Color\s*\(\s*hex\b",
     "Check contrast in light and dark, and supply Increase Contrast variants (asset catalog or colorSchemeContrast).",
     None, 0),
    ("invalid-session-api",
     r"\.accessibilityActions\s*\(\s*\"|\.accessibilityDirectTouch\s*\(\s*\[",
     "Session sample APIs: use accessibilityAction(named:) and accessibilityDirectTouch(options:).",
     None, 0),
    ("assistive-technology-gate",
     r"\bUIAccessibility\s*\.\s*isVoiceOverRunning\b|\baccessibilityVoiceOverEnabled\b|\bisSwitchControlRunning\b|"
     r"\bisApplicationAccessibilityEnabled\b",
     "Use assistive-technology flags only to adapt behavior, never to decide whether accessibility is provided.",
     None, 0),
)
COMPILED_LINE_RULES = tuple((rule, re.compile(pattern), guidance, suppress, window)
                            for rule, pattern, guidance, suppress, window in LINE_RULES)

LABEL_LITERAL = re.compile(r'accessibilityLabel\s*(?:\(|=)\s*(?:Text\s*\(\s*)?"((?:[^"\\]|\\.)*)"')
ROLE_WORDS = re.compile(r"\b(?:button|image|icon|picture|graphic|checkbox|tab|link|selected|unselected)\b", re.I)
IDENTIFIER_LIKE = re.compile(r"^(?:[A-Z0-9]+(?:_[A-Z0-9]+)+|[a-z0-9]+(?:[._-][a-z0-9]+)+|[a-z]+(?:[A-Z][a-z0-9]*)+)$")
ASSET_IMAGE = re.compile(r'\bImage\s*\(\s*"')
SYMBOL_IMAGE = re.compile(r"\bImage\s*\(\s*systemName\s*:")
MOTION = re.compile(r"\.repeatForever\s*\(|\bUIInterpolatingMotionEffect\b|\.addMotionEffect\s*\(|"
                    r"\brepeatCount\s*=\s*(?:\.infinity|Float\s*\.\s*infinity|\.greatestFiniteMagnitude)")
REDUCE_MOTION = re.compile(r"[Rr]educeMotion")
DELAY = re.compile(r"\basyncAfter\s*\(|\bTimer\s*\.\s*scheduledTimer|\bTask\s*\.\s*sleep\b")
DISMISS = re.compile(r"\bdismiss\s*\(|\bisPresented\s*=\s*false|\bremoveFromSuperview\s*\(|\bisHidden\s*=\s*true|"
                     r"\bis\w*(?:Visible|Showing|Shown|Presented)\s*=\s*false|\bhide\w*\s*\(")
DRAWING = re.compile(r"\boverride\s+func\s+(?:draw\s*\(\s*_|touchesBegan\s*\(|mouseDown\s*\(\s*with)")


def mask_non_code(source):
    """Blank comments and string contents while keeping offsets, lines, and string delimiters."""
    result = list(source)
    i = 0
    n = len(source)

    def blank(start, end):
        for position in range(start, min(end, n)):
            if result[position] != "\n":
                result[position] = " "

    while i < n:
        if source.startswith("//", i):
            end = source.find("\n", i)
            end = n if end < 0 else end
            blank(i, end)
            i = end
        elif source.startswith("/*", i):
            start, depth = i, 1
            i += 2
            while i < n and depth:
                if source.startswith("/*", i):
                    depth, i = depth + 1, i + 2
                elif source.startswith("*/", i):
                    depth, i = depth - 1, i + 2
                else:
                    i += 1
            blank(start, i)
        elif source.startswith('"""', i):
            end = source.find('"""', i + 3)
            end = n if end < 0 else end
            blank(i + 3, end)
            i = end + 3
        elif source[i] == '"':
            start = i + 1
            i += 1
            while i < n and source[i] not in '"\n':
                i += 2 if source[i] == "\\" else 1
            blank(start, i)
            i += 1
        else:
            i += 1
    return "".join(result)


def files_under(root, warnings):
    if root.is_file():
        return [root] if root.suffix in SUFFIXES else []
    paths = []

    def report_error(error):
        warnings.append(str(error))

    for directory, dirs, files in os.walk(root, followlinks=False, onerror=report_error):
        dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS and not (Path(directory) / d).is_symlink())
        for name in sorted(files):
            path = Path(directory) / name
            if path.suffix in SUFFIXES and not path.is_symlink():
                paths.append(path)
    return sorted(paths)


def nearby(lines, index, window, pattern):
    low, high = max(0, index - window), min(len(lines), index + window + 1)
    return any(pattern.search(lines[j]) for j in range(low, high))


BUTTON_START = re.compile(r"\bButton\b|label\s*:")
TEXT_IN_LABEL = re.compile(r"\bLabel\s*\(|\bText\s*\(|Button\s*\(\s*\"")


def is_icon_only_button(lines, index):
    """An SF Symbol directly inside a Button label with no text and no nearby accessibility label."""
    if not any(BUTTON_START.search(lines[j]) for j in range(max(0, index - 3), index + 1)):
        return False
    if any(TEXT_IN_LABEL.search(lines[j]) for j in range(max(0, index - 2), min(len(lines), index + 2))):
        return False
    return not any("accessibilityLabel" in lines[j] for j in range(max(0, index - 3), min(len(lines), index + 5)))


def audit_source(source, masked):
    """Return (rule, 0-based line index, guidance) candidates for one file."""
    raw_lines = source.splitlines()
    lines = masked.splitlines()
    found = []

    for rule, pattern, guidance, suppress, window in COMPILED_LINE_RULES:
        for index, line in enumerate(lines):
            if pattern.search(line):
                if suppress is not None and nearby(lines, index, window, suppress):
                    continue
                found.append((rule, index, guidance))

    for index, line in enumerate(lines):
        raw = raw_lines[index] if index < len(raw_lines) else ""
        if "accessibilityLabel" in line:
            for match in LABEL_LITERAL.finditer(raw):
                text = match.group(1)
                if ROLE_WORDS.search(text):
                    found.append(("label-includes-role", index,
                                  "Don't put the element type or state in labels; traits and values carry them."))
                elif IDENTIFIER_LIKE.match(text):
                    found.append(("label-looks-like-identifier", index,
                                  "Labels are spoken to people; move test IDs to accessibilityIdentifier."))
        if ASSET_IMAGE.search(line) and not nearby(lines, index, 3, ACCESSIBILITY_NEARBY):
            found.append(("unlabeled-image", index,
                          "Describe meaningful images, or use Image(decorative:) / accessibilityHidden for decoration."))
        if SYMBOL_IMAGE.search(line) and is_icon_only_button(lines, index):
            found.append(("icon-only-button", index,
                          "Give icon-only buttons a label that names the action; verify SF Symbol default labels."))
        if DELAY.search(line) and any(DISMISS.search(lines[j]) for j in range(index, min(len(lines), index + 7))):
            found.append(("timed-dismissal", index,
                          "Avoid auto-dismissing UI; keep it while assistive focus is on it, or let people extend the time."))

    if not REDUCE_MOTION.search(masked):
        for index, line in enumerate(lines):
            if MOTION.search(line):
                found.append(("motion-without-reduce-motion", index,
                              "Repeating or parallax motion needs a Reduce Motion alternative."))

    if "accessib" not in masked.lower():
        for index, line in enumerate(lines):
            if DRAWING.search(line):
                found.append(("custom-drawing-without-accessibility", index,
                              "Custom-drawn or touch-handling views expose nothing until you add elements, labels, and actions."))

    for index, line in enumerate(lines):
        if "accessibilityRotor" in line:
            for j in range(index + 1, min(len(lines), index + 8)):
                if re.search(r"\bif\b", lines[j]) and any("AccessibilityRotorEntry" in lines[k]
                                                           for k in range(j, min(len(lines), j + 3))):
                    found.append(("rotor-builder-if", j,
                                  "An `if` in rotor content needs an iOS 27 deployment target with the Xcode 27 SDK; filter the collection instead."))
                    break
    return found


def audit(root):
    warnings = []
    candidates = []
    scanned = 0
    base = root if root.is_dir() else root.parent
    for path in files_under(root, warnings):
        try:
            source = path.read_text(encoding="utf-8")
        except (OSError, UnicodeError) as error:
            warnings.append(f"{path.relative_to(base)}: {error}")
            continue
        scanned += 1
        masked = mask_non_code(source)
        raw_lines = source.splitlines()
        seen = set()
        for rule, index, guidance in audit_source(source, masked):
            if (rule, index) in seen:
                continue
            seen.add((rule, index))
            candidates.append({"rule": rule, "path": path.relative_to(base).as_posix(), "line": index + 1,
                               "excerpt": raw_lines[index].strip() if index < len(raw_lines) else "",
                               "guidance": guidance})
    candidates.sort(key=lambda item: (item["path"], item["line"], item["rule"]))
    return {"files_scanned": scanned, "candidates": candidates, "warnings": warnings}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", type=Path, help="Project directory or one Swift/Objective-C file")
    parser.add_argument("--json", action="store_true", help="Emit a JSON report")
    args = parser.parse_args()
    if not args.path.exists():
        parser.error(f"Path does not exist: {args.path}")
    report = audit(args.path.absolute())
    if args.json:
        print(json.dumps(report, indent=2))
    else:
        print(f"{report['files_scanned']} files scanned; {len(report['candidates'])} review candidates (not proven bugs).")
        for item in report["candidates"]:
            print(f"{item['path']}:{item['line']}: [{item['rule']}] {item['excerpt']}")
            print(f"  {item['guidance']}")
        for warning in report["warnings"]:
            print(f"Warning: {warning}")
    return 1 if report["warnings"] else 0


if __name__ == "__main__":
    raise SystemExit(main())

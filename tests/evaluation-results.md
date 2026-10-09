# Validation record — 2026-10-09, version 1.0.0

## Completed

- **Audit CLI and package contracts:** all 15 tests pass (`python3 -m unittest discover -s tests -v`). They cover rule locations, comment and string masking, label-literal checks, image and icon-button suppression, gesture and tap windows, the Reduce Motion file guard, rotor `if` detection, session-API typos, timed dismissal, custom drawing, skipped dependency folders and symlinks, single-file and human output, and unreadable or missing inputs. The four package tests from the Duo repository (version drift, marketplace resolution and install policy, links leaving the installed skill) pass unchanged.
- **Package validator:** metadata, manifests, marketplace catalogs, JSON, and every local reference link are valid (`python3 scripts/validate_package.py`).
- **Manifests:** root `plugin.json` validates against the official Agent Plugins 1.0.0 JSON schema; `claude plugin validate --strict` passes for both the Claude plugin manifest and the marketplace; `agents/openai.yaml` parses as YAML; the Skills CLI discovers exactly one skill with the expected description.
- **Examples:** all nine Swift files type-check under Swift 6 with Xcode 27.1 (27A9269) for iOS 17, Mac Catalyst 17, macOS 14 (AppKit and charts), and an iOS 17 simulator UI-test target (`./scripts/check_examples.sh`).
- **SDK probe:** every API the references recommend was type-checked in a scratch probe against an iOS 17 deployment target with availability gates. The probe surfaced the corrections recorded in the API catalog: `accessibilityAction(named:)`, `accessibilityDirectTouch(options:)`, `if` in rotor builders requiring iOS 27, ambiguous `accessibilityCustomContent` string overloads, `UIHostingSceneDelegate` being a protocol, and the iOS 18 or 26.4 availability of several settings and caption-preview APIs.
- **Audit dogfooding:** on the skill's own examples, the helper reports three `hidden-from-accessibility` candidates, each an intentional decorative or duplicated element. On a deliberately broken fixture, every rule fired at the expected line.

## Not yet run

- No independent forward evaluation of `skill_evals.json` has been run; the scenarios are maintained evaluation inputs, not executed trials. Run them with a fresh agent that receives only the skill and realistic app artifacts, and record results here.
- Nothing was exercised with VoiceOver, Voice Control, Switch Control, or Full Keyboard Access on a device or simulator; spoken output and focus behavior of the examples are unverified.
- Declarations verified without behavior checks: `accessibilitySpeechSSML`, `MACaptionAppearanceDomain.videoConferencing`, `AccessibilitySettings.isApplicationAccessibilityEnabled`, and `XCUIVoiceOverService` at runtime.
- The repository hasn't been pushed to GitHub or submitted to any plugin directory.

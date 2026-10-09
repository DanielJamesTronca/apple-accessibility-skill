# App Store Accessibility Nutrition Labels

Product pages show which of nine accessibility features an app supports, per device, on devices running the 26 releases or later. Search can match them ("VoiceOver note-taking apps"). Labels are voluntary for now; App Store Connect says they'll become required for new apps and updates "over time". Accurate labels fall under App Review Guideline 2.3, and App Review can ask you to correct misleading ones. [Overview of Accessibility Nutrition Labels](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels), [Evaluate your app for Accessibility Nutrition Labels](https://developer.apple.com/videos/play/wwdc2025/224/).

## The decision rule

Claim a feature for a device only if people can complete **all common tasks** on that device using that feature. Common tasks are the primary functionality plus first launch or onboarding, sign-in and account creation, purchase, and settings. Include mandatory flows, empty and loading states, and tasks commonly done from notifications or widgets. Include ads if they appear during common tasks. Include extensions only if they're part of common tasks. If unsure whether a task is common, ask: "Would we ship an urgent fix if people were blocked here?" If bugs would change the answer, don't claim the feature yet. If a feature doesn't apply (for example captions in an app with no audio or video), don't claim it; that's accurate, not a failure.

Recommended order: VoiceOver, then Voice Control (they share most work), then the visual features, then media.

| Label | Devices | Claim when… | Key traps |
| --- | --- | --- | --- |
| VoiceOver | All | Every visible element is reachable and operable; labels concise and contextual; types and states via traits; all text spoken; custom text entry works; logical, loop-free order; focus moves into modals and background is unreachable; escape dismisses; status messages announced; long press, drag, and multi-touch available as actions or rotors; charts have a chart API or text alternative | Must be native VoiceOver support—no custom screen readers |
| Voice Control | iPhone, iPad, Mac, Vision Pro (not TV or Watch) | Everything tappable has a name or number; names match visible text; hidden, hover, and swipe UI reachable by speech; scroll, pan, and zoom work; dictation and text editing work in every field; recording starts and stops by voice | Labels that differ from visible text; gesture-only actions |
| Larger Text | All but Mac | Text and meaningful icons enlarge to at least 200% (or the system maximum: >140% on Watch; largest size on tvOS) without overlap or unreadable truncation; layouts reflow | Zoom or Hover Text doesn't count; in-app size controls count if equivalent |
| Dark Interface | All | Dark by default, or a mode keeps it dark through all common tasks (system Dark Mode, a custom dark theme, or as a last resort Smart Invert with media not inverted) | Bright flashes or white web pages mid-task; failing contrast in dark mode |
| Differentiate Without Color Alone | All | Common tasks never rely on color alone, or people can choose palettes | Status dots, chart series, form errors, selected states |
| Sufficient Contrast | All | Text meets about 4.5:1 by default, or Increase Contrast (or a selectable scheme) achieves it, including non-text state at 3:1; translucency considered | Test with Bold Text + Increase Contrast + Reduce Transparency, and with Increase Contrast alone |
| Reduced Motion | All | No problematic motion with the setting on (depth simulation, parallax, animated blur, spinning, vortex, multi-axis or multi-speed motion, auto-advancing content), or alternatives provided | Removing meaningful animation entirely instead of replacing it with fades |
| Captions | All | Video and audio dialogue (including game interstitials) have captions or subtitles; audio-only content has transcripts; on by default when the system setting asks; captioned items are identifiable | Claiming it with a caption feature but little captioned content |
| Audio Descriptions | All | Video, cutscenes, and visual-only hints have narrated descriptions; auto-selected per the system setting; AD content is identifiable | Same as captions |

Criteria pages: [VoiceOver](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/voiceover-evaluation-criteria), [Voice Control](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/voice-control-evaluation-criteria), [Larger Text](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/larger-text-evaluation-criteria), [Dark Interface](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/dark-interface-evaluation-criteria), [Differentiate Without Color Alone](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/differentiate-without-color-alone-evaluation-criteria), [Sufficient Contrast](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/sufficient-contrast-evaluation-criteria), [Reduced Motion](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/reduced-motion-evaluation-criteria), [Captions](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/captions-evaluation-criteria), [Audio Descriptions](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/audio-descriptions-evaluation-criteria).

## Implementation latitude

- VoiceOver and Voice Control must be supported natively; never reimplement them.
- The other features may use custom implementations (a custom dark theme, an in-app text-size control, your own caption renderer). Default them from the system setting, and offer more granular control than the system rather than less.
- Third-party and user-generated content: you aren't responsible for every item, but creators need a reasonable, discoverable way to make content accessible (alt text on uploads, caption tracks), and people need to see which items are accessible. WebKit handles standard web content.
- A reasonable exception: hiding a duplicate control from VoiceOver when the same function is discoverable elsewhere.

## Process

1. List common tasks per device; build a task × feature matrix (only features available on that device).
2. Learn each technology well enough to test it (Apple links platform user guides from each criteria page).
3. Evaluate, fix, and re-evaluate. Partner with people who use the features; test custom elements especially carefully.
4. In App Store Connect: Apps → app → **App Accessibility** → Get Started → per device, Yes/No → select features → Publish. Publishing requires a live version for that device. Changes take up to 24 hours to appear. Roles allowed: Account Holder, Admin, Finance, App Manager, Marketing. The App Store Connect API can manage labels too. [Manage Accessibility Nutrition Labels](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/manage-accessibility-nutrition-labels).
5. Optionally add an **accessibility URL** (not shown on Apple TV) describing extra features, in-app settings, caption languages, or known gaps.
6. Re-evaluate on every release and update responses when support changes.

iPhone and iPad apps running on Apple silicon Macs or Vision Pro show their iPhone and iPad labels; no separate answers are needed there.

## When asked "can we claim X?"

Answer per device and per feature with evidence: the tasks tested, the settings and technologies used, the failures found (with severity), and a yes, no, or not-applicable recommendation. Distinguish polish issues that don't block information (a misaligned title) from blockers (a truncated description, a text field that doesn't grow, an unlabeled control in checkout). Never recommend claiming a feature on the basis of an audit or code review alone.

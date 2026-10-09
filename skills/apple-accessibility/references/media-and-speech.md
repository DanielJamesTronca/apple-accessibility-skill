# Media, hearing, speech, and haptics

Don't communicate dialogue or crucial information through audio alone, and don't make visual-only media inaccessible to blind people. Pair audio cues with visual and haptic ones. [HIG: Accessibility – Hearing](https://developer.apple.com/design/human-interface-guidelines/accessibility).

## Captions and subtitles

Forms of text alternative:

- **Subtitles:** dialogue, often in another language.
- **Closed captions / SDH:** dialogue plus speakers and meaningful sounds ("[doorbell rings]").
- **Transcripts:** full text of audio-only content (podcasts, lyrics); they don't need to be time-synchronized.

Implementation:

- `AVPlayerViewController` (iOS, tvOS, visionOS) and `AVPlayerView` (macOS) handle caption selection, rendering, and people's caption styles. For a custom player, add `AVLegibleMediaOptionsMenuController` (iOS 26.4) for the selection menu, or build your own using `AVMediaSelectionGroup` for `.legible`.
- Turn captions on by default when the system preference asks for them: `UIAccessibility.isClosedCaptioningEnabled` and `MACaptionAppearanceGetDisplayType(.user)`. In-app caption settings should start from the system values.
- Custom renderers must apply the person's caption style from MediaAccessibility: font, size (`MACaptionAppearanceGetRelativeCharacterSize`), foreground, background, and window color and opacity, and edge style. Observe `kMACaptionAppearanceSettingsChangedNotification` and call `MACaptionAppearanceDidDisplayCaptions` so assistive technologies, including braille displays, receive the text. [Captions](https://developer.apple.com/documentation/mediaaccessibility/captions).
- Mark tracks with the right characteristics (`transcribesSpokenDialogForAccessibility`, `describesMusicAndSoundForAccessibility`) so the system can pick SDH automatically.
- Show which items have captions (CC, SDH badges) and which have audio descriptions (AD), and the available languages.
- Caption game cutscenes, onboarding videos, and in-app clips too—not just a movie catalog. In spatial apps, include sound direction and use pop-on (whole-phrase) rather than roll-up captions. [Create accessible spatial experiences](https://developer.apple.com/videos/play/wwdc2023/10034/).

**iOS 27 generated subtitles.** iOS and macOS 27 generate English subtitles from English audio on device (also on tvOS and visionOS 27) and translate from English subtitles into other languages (iOS and macOS). This works automatically for HLS (live and on demand) and file-based playback. Authored subtitles stay preferred; generated ones are marked "Translated" with a sparkle. Your app's job is to provide a subtitle selection UI. **Subtitle style preview** lets people try caption styles during playback: AVKit players include it, `AVLegibleMediaOptionsMenuController` provides it, and custom layers can call `AVPlayerLayer.setCaptionPreviewProfileID(_:position:text:)` and `stopShowingCaptionPreview()` (iOS 26.4) with profile IDs from `MACaptionAppearanceCopyProfileIDs()`; apply the choice with `MACaptionAppearanceSetActiveProfileID`. [Discover generated subtitles and subtitle styles](https://developer.apple.com/videos/play/wwdc2026/256/). A developer reported generated subtitles missing on tvOS 27 betas with resource-loader-based playback; it was resolved in the release without code changes. Treat beta behavior as unverified. [Forum thread](https://developer.apple.com/forums/thread/844204).

## Audio descriptions

Audio descriptions narrate visual-only information in pauses of the main audio. Provide AD tracks for video content, intros, and cutscenes, plus spoken versions of visual-only hints in games. Auto-select them when `MAAudibleMediaCopyPreferredCharacteristics()` includes `MAMediaCharacteristicDescribesVideoForAccessibility` (AVFoundation honors this automatically). [Audio Descriptions criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/audio-descriptions-evaluation-criteria).

## Flashing lights

With Dim Flashing Lights on, AVFoundation dims detected flashing automatically. Custom video pipelines can run frames through `MAFlashingLightsProcessor`. Read `MADimFlashingLightsEnabled()` (or SwiftUI `\.accessibilityDimFlashingLights`) to annotate risky segments, play alternate assets, or tone down game effects. [Responding to changes in the flashing lights setting](https://developer.apple.com/documentation/mediaaccessibility/responding-to-changes-in-the-flashing-lights-setting).

## Music Haptics (iOS 18)

Music Haptics lets deaf and hard-of-hearing people feel music. To support it:

1. Add `MusicHapticsSupported = YES` to Info.plist.
2. Publish the playing song's ISRC in `MPNowPlayingInfoCenter.default().nowPlayingInfo` under `MPNowPlayingInfoPropertyInternationalStandardRecordingCode`.
3. Observe `MAMusicHapticsManager.shared.isActive` and `activeStatusDidChangeNotification`. Check availability with `checkHapticTrackAvailabilityForMedia(matchingCode:completionHandler:)`.
4. Show status with the `apple.haptics.and.music.note`, `.slash`, and `apple.haptics.and.exclamationmark.triangle` symbols.

[Music Haptics](https://developer.apple.com/documentation/mediaaccessibility/music-haptics).

## Haptics and sound as redundancy

Pair success or error sounds with haptics (UIKit feedback generators, SwiftUI `sensoryFeedback`, Core Haptics) and visible state. Augment spatial or off-screen audio cues with visual pointers. Never make haptics the only signal; some people have them disabled. [HIG: Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics).

## Speech synthesis

- Don't build an in-app screen reader. For an occasional status message to VoiceOver users, post an announcement. Use `AVSpeechSynthesizer` when speech is the product for everyone: navigation directions, AAC apps, scene description. The UI must still be fully accessible. [Create a seamless speech experience in your apps](https://developer.apple.com/videos/play/wwdc2020/10022/).
- Retain the synthesizer until speech finishes. Utterances use Spoken Content settings by default; Siri voices aren't available to the API.
- `utterance.prefersAssistiveTechnologySettings = true` (iOS 14) uses the running assistive technology's voice, rate, and pitch so speech blends with VoiceOver. It overrides explicit properties, so skip it for AAC apps with custom voices.
- `mixToTelephonyUplink` routes speech into an active call (AAC). `usesApplicationAudioSession = false` lets the system manage, duck, and mix speech audio.
- SSML: `AVSpeechUtterance(ssmlRepresentation:)` (iOS 17) supports breaks, prosody, phonemes, and language changes; Safari's Web Speech API accepts SSML too.
- Personal Voice (iOS 17): `AVSpeechSynthesizer.requestPersonalVoiceAuthorization` and voices with the `.isPersonalVoice` trait. Treat it as sensitive and intended mainly for augmentative and alternative communication. Live Speech lets people type to speak in calls. [Extend Speech Synthesis with personal and custom voices](https://developer.apple.com/videos/play/wwdc2023/10033/).
- Speech synthesis providers: an Audio Unit extension (`AVSpeechSynthesisProviderAudioUnit`) can supply system-wide voices, including for VoiceOver. Call `AVSpeechSynthesisProviderVoice.updateSpeechVoices()` when available voices change; observe `AVSpeechSynthesizer.availableVoicesDidChangeNotification`.
- Apple's accessibility team reported no new text-to-speech APIs in the 27 releases. [Group Lab, 16:29](https://developer.apple.com/videos/play/wwdc2026/8005/?time=989).

## Hearing devices and calls

- Hearing-aid companion apps (with the `hearing.aid.app` entitlement) can read paired device identifiers, streaming ear, and bidirectional streaming support through `AXMFiHearingDevice`, and ask people to enable streaming when needed. [Hearing device support](https://developer.apple.com/documentation/accessibility/hearing-device-support).
- Mono Audio and audio balance settings mean stereo-only cues (left ear versus right ear) can be lost; don't encode meaning in channel placement alone.
- Video-calling apps: iOS and macOS 27 add a `videoConferencing` case to `MACaptionAppearanceDomain`. The checked SDK documents no semantics beyond its name; inspect it before relying on separate styling for call captions.

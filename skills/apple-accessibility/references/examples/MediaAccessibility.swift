// Original examples for the apple-accessibility skill. Type-checked with Swift 6 for iOS 17+.
import AVFoundation
import MediaAccessibility
import MediaPlayer
import UIKit

// MARK: Captions on by default when the person asked for them.

@MainActor func prefersCaptions() -> Bool {
    UIAccessibility.isClosedCaptioningEnabled
        || MACaptionAppearanceGetDisplayType(.user) == .alwaysOn
}

@MainActor func selectLegibleOption(for item: AVPlayerItem) async {
    guard prefersCaptions(),
          let group = try? await item.asset.loadMediaSelectionGroup(for: .legible) else { return }
    // Prefer SDH/closed captions that describe sounds as well as dialogue.
    let sdh = group.options.first { $0.hasMediaCharacteristic(.describesMusicAndSoundForAccessibility) }
    item.select(sdh ?? group.defaultOption, in: group)
}

// MARK: A custom caption renderer applies the person's caption style.

struct CaptionStyle {
    var foreground: CGColor
    var background: CGColor
    var relativeSize: CGFloat
}

func currentCaptionStyle() -> CaptionStyle {
    var behavior = MACaptionAppearanceBehavior.useValue
    let foreground = MACaptionAppearanceCopyForegroundColor(.user, &behavior).takeRetainedValue()
    let background = MACaptionAppearanceCopyBackgroundColor(.user, &behavior).takeRetainedValue()
    let size = MACaptionAppearanceGetRelativeCharacterSize(.user, &behavior)
    return CaptionStyle(foreground: foreground, background: background, relativeSize: size)
}

// MARK: Subtitle style preview on a custom player layer (iOS 26.4+).

@available(iOS 26.4, *)
@MainActor func previewSubtitleStyle(_ profileID: String, on layer: AVPlayerLayer) {
    layer.setCaptionPreviewProfileID(profileID, position: .zero, text: nil) // nil shows localized sample text.
}

@available(iOS 26.4, *)
@MainActor func commitSubtitleStyle(_ profileID: String, on layer: AVPlayerLayer) {
    layer.stopShowingCaptionPreview()
    MACaptionAppearanceSetActiveProfileID(profileID as CFString) // Applies system-wide.
}

// MARK: Dim Flashing Lights.

final class FlashingLightsObserver {
    private(set) var isDimmingEnabled = MADimFlashingLightsEnabled()
    var onChange: (Bool) -> Void = { _ in }

    init() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(changed),
            name: NSNotification.Name(kMADimFlashingLightsChangedNotification as String), object: nil)
    }

    @objc private func changed() {
        isDimmingEnabled = MADimFlashingLightsEnabled()
        onChange(isDimmingEnabled) // Swap to calmer assets or annotate risky segments.
    }
}

// MARK: Music Haptics (iOS 18+): also set MusicHapticsSupported = YES in Info.plist.

@available(iOS 18.0, *)
@MainActor func publishNowPlaying(title: String, isrc: String) {
    var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
    info[MPMediaItemPropertyTitle] = title
    info[MPNowPlayingInfoPropertyInternationalStandardRecordingCode] = isrc
    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    _ = MAMusicHapticsManager.shared.isActive // Observe activeStatusDidChangeNotification to update UI.
}

// MARK: Speech that blends with VoiceOver, for speech-centric features only.

@MainActor final class Narrator {
    private let synthesizer = AVSpeechSynthesizer() // Keep a strong reference until speech ends.

    init() {
        synthesizer.usesApplicationAudioSession = false // Let the system manage ducking and interruptions.
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.prefersAssistiveTechnologySettings = true // Use VoiceOver's voice, rate, and pitch when running.
        synthesizer.speak(utterance)
    }
}

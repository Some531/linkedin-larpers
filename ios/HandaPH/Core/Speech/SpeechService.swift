import AVFoundation

/// Text-to-speech for alerts and glossary entries. One shared instance so a
/// new utterance always stops the previous one.
@MainActor
final class SpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    /// The text currently being spoken; nil when idle. Buttons compare
    /// against their own text so only the active one shows "Stop".
    @Published private(set) var currentText: String?

    /// AVSpeechUtterance rate value; persisted. Defaults a little below
    /// normal — clearer for elderly listeners. The Settings slider bounds
    /// (0.3–0.55) keep it inside the intelligible range.
    @Published var rate: Double {
        didSet { UserDefaults.standard.set(rate, forKey: "speechRate") }
    }

    /// Whether iOS provides a Filipino voice on this device. Often false on
    /// stock installs — Philippine-language text then falls back to an
    /// English voice, a limitation we surface in Settings rather than hide.
    static var hasFilipinoVoice: Bool {
        AVSpeechSynthesisVoice(language: "fil-PH") != nil
    }

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        let stored = UserDefaults.standard.double(forKey: "speechRate")
        rate = stored == 0 ? 0.42 : stored
        super.init()
        synthesizer.delegate = self
    }

    func isSpeaking(_ text: String) -> Bool { currentText == text }

    func speak(_ text: String, language: AppLanguage) {
        stop()
        guard !text.isEmpty else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        let utterance = AVSpeechUtterance(string: text)
        // Explicit fallback: never rely on the silent device-locale default.
        utterance.voice = AVSpeechSynthesisVoice(language: language.speechVoiceCode)
            ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = Float(rate)
        synthesizer.speak(utterance)
        currentText = text
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        finish()
    }

    /// Releases the audio session so other apps' audio (e.g. a radio stream
    /// during a disaster) stops being ducked.
    private func finish() {
        currentText = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.finish() }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.finish() }
    }
}

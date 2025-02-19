import Foundation
import AVFoundation

protocol SpeechSynthesizerInterface {
    func speak(_ text: String)
}

final class SpeechSynthesizer: SpeechSynthesizerInterface {

    private let speechSynthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        guard !speechSynthesizer.isSpeaking else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}

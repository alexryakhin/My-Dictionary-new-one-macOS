import Foundation
import AVKit

final class SpeechSynthesizer: NSObject {

    static let shared = SpeechSynthesizer()

    private var speechSynthesizer: AVSpeechSynthesizer?

    private override init() {
        super.init()
    }

    func speak(_ text: String) {
        speechSynthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        speechSynthesizer?.speak(utterance)
        speechSynthesizer = nil
    }
}

import AVFoundation
import Foundation

/// Plays the completion sound bundled with the app.
@MainActor
final class SoundPlayer {
    static let shared = SoundPlayer()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    func playPenguin() {
        guard let url = Bundle.module.url(forResource: "emperor_penguin_trumpet", withExtension: "mp3") else {
            NSLog("PenguinTomato sound missing: emperor_penguin_trumpet.mp3 not found in bundle")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            NSLog("PenguinTomato sound error: \(error.localizedDescription)")
        }
    }
}

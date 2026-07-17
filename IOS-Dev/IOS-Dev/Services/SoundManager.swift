import Foundation
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()
    
    private init() {}
    
    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "soundsEnabled") || UserDefaults.standard.object(forKey: "soundsEnabled") == nil
    }
    
    enum SoundType: SystemSoundID {
        case tap = 1104       // Tock click (perfect for quick taps)
        case correct = 1057   // Tink chime (positive response)
        case incorrect = 1053 // Buzz beep (negative response)
        case victory = 1025   // Trumpet level-up fanfare (new high score)
    }
    
    func play(_ sound: SoundType) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(sound.rawValue)
    }
}

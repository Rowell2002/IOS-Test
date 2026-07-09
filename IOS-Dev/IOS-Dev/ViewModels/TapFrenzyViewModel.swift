import SwiftUI
import Combine

class TapFrenzyViewModel: ObservableObject {
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "panicHighScore") {
        didSet {
            UserDefaults.standard.set(highScore, forKey: "panicHighScore")
        }
    }
    @Published var playerName: String = UserDefaults.standard.string(forKey: "savedPlayerName") ?? "Guest" {
        didSet {
            UserDefaults.standard.set(playerName, forKey: "savedPlayerName")
        }
    }
    
    @Published var pressCount = 0
    @Published var timeLeft = 10
    @Published var timerStarted = false
    @Published var isPersonalBestSet = false
    
    private var timerSubscription: AnyCancellable?
    
    func loadPlayerName() {
        playerName = UserDefaults.standard.string(forKey: "savedPlayerName") ?? "Guest"
    }
    
    func buttonPressed() {
        if !timerStarted {
            startTimer()
        }
        pressCount += 1
        
        // Haptic feedback & Sound effect for tapping
        HapticManager.shared.impact(style: .light)
        SoundManager.shared.play(.tap)
    }
    
    private func startTimer() {
        timerStarted = true
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeLeft > 0 && self.timerStarted {
                    self.timeLeft -= 1
                    
                    // Trigger haptic & tick warning sound during last 3 seconds
                    if self.timeLeft <= 3 && self.timeLeft > 0 {
                        HapticManager.shared.impact(style: .medium)
                        SoundManager.shared.play(.incorrect) // Buzz warning tick
                    }
                    
                    if self.timeLeft == 0 {
                        self.timerSubscription?.cancel()
                        
                        var newHigh = false
                        if self.pressCount > self.highScore {
                            self.highScore = self.pressCount
                            self.isPersonalBestSet = true
                            newHigh = true
                        }
                        
                        let name = self.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Guest" : self.playerName
                        ScoreHistoryManager.saveScore(self.pressCount, playerName: name, for: "tapFrenzyHistory")
                        GameSessionManager.shared.saveSession(gameMode: "Tap Frenzy", score: self.pressCount)
                        
                        // Play final sound & haptic
                        if newHigh {
                            HapticManager.shared.notification(type: .success)
                            SoundManager.shared.play(.victory)
                        } else {
                            HapticManager.shared.notification(type: .warning)
                            SoundManager.shared.play(.incorrect)
                        }
                    }
                }
            }
    }
    
    func replay() {
        timerSubscription?.cancel()
        pressCount = 0
        timeLeft = 10
        timerStarted = false
        isPersonalBestSet = false
    }
    
    func cancelTimer() {
        timerSubscription?.cancel()
    }
}

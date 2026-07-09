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
    
    private var timerSubscription: AnyCancellable?
    
    func loadPlayerName() {
        playerName = UserDefaults.standard.string(forKey: "savedPlayerName") ?? "Guest"
    }
    
    func buttonPressed() {
        if !timerStarted {
            startTimer()
        }
        pressCount += 1
    }
    
    private func startTimer() {
        timerStarted = true
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeLeft > 0 && self.timerStarted {
                    self.timeLeft -= 1
                    if self.timeLeft == 0 {
                        self.timerSubscription?.cancel()
                        if self.pressCount > self.highScore {
                            self.highScore = self.pressCount
                        }
                        let name = self.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Guest" : self.playerName
                        ScoreHistoryManager.saveScore(self.pressCount, playerName: name, for: "tapFrenzyHistory")
                        GameSessionManager.shared.saveSession(gameMode: "Tap Frenzy", score: self.pressCount)
                    }
                }
            }
    }
    
    func replay() {
        timerSubscription?.cancel()
        pressCount = 0
        timeLeft = 10
        timerStarted = false
    }
    
    func cancelTimer() {
        timerSubscription?.cancel()
    }
}

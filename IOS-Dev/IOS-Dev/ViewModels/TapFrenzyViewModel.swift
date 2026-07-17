import SwiftUI
import Combine

struct PowerUpBubble: Identifiable, Equatable {
    let id = UUID()
    let xOffset: CGFloat
    let yOffset: CGFloat
    let value: Int
}

class TapFrenzyViewModel: ObservableObject {
    @Published var highScore: Int = 0
    @Published var playerName: String = UserDefaults.standard.string(forKey: "savedPlayerName") ?? "Guest" {
        didSet {
            UserDefaults.standard.set(playerName, forKey: "savedPlayerName")
        }
    }
    
    @Published var pressCount = 0
    @Published var timeLeft = 10
    @Published var timerStarted = false
    @Published var isPersonalBestSet = false
    @Published var activeBubble: PowerUpBubble? = nil
    
    private var bubbleTimeLeft = 0
    private var timerSubscription: AnyCancellable?
    
    func loadPlayerName() {
        playerName = UserDefaults.standard.string(forKey: "savedPlayerName") ?? "Guest"
        let key = AuthManager.shared.currentUser.map { "panicHighScore_\($0.email)" } ?? "panicHighScore"
        highScore = UserDefaults.standard.integer(forKey: key)
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
    
    func bubbleTapped() {
        guard let bubble = activeBubble else { return }
        pressCount += bubble.value
        activeBubble = nil
        
        // Special feedback for popping bubble
        HapticManager.shared.notification(type: .success)
        SoundManager.shared.play(.correct)
    }
    
    private func startTimer() {
        timerStarted = true
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeLeft > 0 && self.timerStarted {
                    self.timeLeft -= 1
                    
                    // Manage bubble duration
                    if self.activeBubble != nil {
                        self.bubbleTimeLeft -= 1
                        if self.bubbleTimeLeft <= 0 {
                            self.activeBubble = nil
                        }
                    }
                    
                    // Spawn bubble randomly (35% chance, if none is active and timeLeft > 1)
                    if self.activeBubble == nil && self.timeLeft > 1 && Double.random(in: 0...1) < 0.35 {
                        let x = CGFloat.random(in: -100...100)
                        let y = CGFloat.random(in: -150...150)
                        self.activeBubble = PowerUpBubble(xOffset: x, yOffset: y, value: 3)
                        self.bubbleTimeLeft = 2
                    }
                    
                    // Trigger haptic & tick warning sound during last 3 seconds
                    if self.timeLeft <= 3 && self.timeLeft > 0 {
                        HapticManager.shared.impact(style: .medium)
                        SoundManager.shared.play(.incorrect) // Buzz warning tick
                    }
                    
                    if self.timeLeft == 0 {
                        self.timerSubscription?.cancel()
                        self.activeBubble = nil
                        
                        var newHigh = false
                        if self.pressCount > self.highScore {
                            self.highScore = self.pressCount
                            self.isPersonalBestSet = true
                            newHigh = true
                            let key = AuthManager.shared.currentUser.map { "panicHighScore_\($0.email)" } ?? "panicHighScore"
                            UserDefaults.standard.set(self.pressCount, forKey: key)
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
        activeBubble = nil
        bubbleTimeLeft = 0
    }
    
    func cancelTimer() {
        timerSubscription?.cancel()
        activeBubble = nil
    }
}

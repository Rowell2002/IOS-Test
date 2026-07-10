import SwiftUI
import Combine

enum LightItUpMode: String, CaseIterable, Identifiable {
    case standard = "Frenzy"
    case memory = "Simon Says"
    
    var id: String { self.rawValue }
}

class LightItUpViewModel: ObservableObject {
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "tilesHighScore") {
        didSet {
            UserDefaults.standard.set(highScore, forKey: "tilesHighScore")
        }
    }
    
    @Published var playerName: String = UserDefaults.standard.string(forKey: "savedPlayerName") ?? "Guest" {
        didSet {
            UserDefaults.standard.set(playerName, forKey: "savedPlayerName")
        }
    }
    
    @Published var currentScore = 0
    @Published var timeLeft = 60
    @Published var level = 1
    @Published var lives = 3
    @Published var isPersonalBestSet = false
    @Published var gameMode: LightItUpMode = .standard
    @Published var isPlayingSequence = false
    
    @Published var showLevelUp = false
    @Published var activeIndices: Set<Int> = []
    @Published var isActive = false
    @Published var interval: Double = 1.5
    @Published var gameStarted = false
    @Published var elapsedTime = 0
    @Published var glowColor: Color = .yellow
    @Published var timerStarted = false
    
    var simonSequence: [Int] = []
    var playerInputIndex = 0
    private var gameTimerSubscription: AnyCancellable?
    
    func loadPlayerName() {
        playerName = UserDefaults.standard.string(forKey: "savedPlayerName") ?? "Guest"
    }
    
    var gridSize: (rows: Int, cols: Int) {
        if gameMode == .memory {
            switch level {
            case 1:
                return (2, 2)
            case 2:
                return (3, 3)
            case 3:
                return (4, 4)
            default:
                return (2, 2)
            }
        } else {
            switch level {
            case 1:
                return (2, 2)
            case 2:
                return (3, 3)
            case 3, 4:
                return (4, 4)
            default:
                return (2, 2)
            }
        }
    }
    
    var totalCards: Int {
        gridSize.rows * gridSize.cols
    }
    
    var numActiveCards: Int {
        level == 4 ? 2 : 1
    }
    
    func startGame() {
        activeIndices.removeAll()
        isActive = false
        gameStarted = true
        timeLeft = 60
        lives = 3
        level = 1
        currentScore = 0
        elapsedTime = 0
        timerStarted = false
        glowColor = .yellow
        interval = 1.5
        isPersonalBestSet = false
        isPlayingSequence = false
        
        startTimer()
        
        if gameMode == .memory {
            // Simon Says start sequence setup
            simonSequence = [Int.random(in: 0..<totalCards)]
            playerInputIndex = 0
            isPlayingSequence = true
            timerStarted = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.playSequence()
            }
        } else {
            nextTurn()
        }
    }
    
    func resetGame() {
        gameStarted = false
        timerStarted = false
        isPlayingSequence = false
        activeIndices.removeAll()
        isActive = false
        gameTimerSubscription?.cancel()
        
        startGame()
    }
    
    private func startTimer() {
        gameTimerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timerStarted && self.timeLeft > 0 && self.lives > 0 {
                    if self.gameMode == .standard {
                        self.timeLeft -= 1
                        self.elapsedTime += 1
                        self.updateLevel(forElapsed: self.elapsedTime)
                        
                        if self.timeLeft == 0 {
                            self.gameEnded()
                        }
                    }
                }
            }
    }
    
    func playSequence() {
        guard gameStarted else { return }
        isPlayingSequence = true
        isActive = false
        activeIndices.removeAll()
        
        var delay = 0.0
        let flashDuration = max(0.3, 0.7 - Double(level) * 0.1)
        let gapInterval = flashDuration + 0.2
        
        for (_, tileIndex) in simonSequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard self.gameStarted else { return }
                self.activeIndices = [tileIndex]
                HapticManager.shared.impact(style: .light)
                SoundManager.shared.play(.correct)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + flashDuration) {
                guard self.gameStarted else { return }
                self.activeIndices.removeAll()
            }
            delay += gapInterval
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard self.gameStarted else { return }
            self.isPlayingSequence = false
            self.isActive = true
            self.playerInputIndex = 0
        }
    }
    
    func tileTapped(index: Int) {
        if !timerStarted {
            timerStarted = true
        }
        guard gameStarted && isActive && !isPlayingSequence else { return }
        
        if gameMode == .memory {
            // Memory Says logic
            let expected = simonSequence[playerInputIndex]
            if index == expected {
                // Correct input
                activeIndices = [index]
                HapticManager.shared.impact(style: .light)
                SoundManager.shared.play(.correct)
                
                // Dim tile flash feedback
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if self.activeIndices.contains(index) {
                        self.activeIndices.remove(index)
                    }
                }
                
                playerInputIndex += 1
                
                if playerInputIndex == simonSequence.count {
                    // Sequence fully completed
                    currentScore += 1
                    isActive = false
                    
                    // Advance levels dynamically based on score milestones
                    let oldLevel = level
                    if currentScore >= 8 {
                        level = 3
                        glowColor = .blue
                    } else if currentScore >= 4 {
                        level = 2
                        glowColor = .green
                    }
                    
                    if level != oldLevel {
                        withAnimation {
                            showLevelUp = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                self.showLevelUp = false
                            }
                        }
                    }
                    
                    // Proceed to next longer sequence round
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.playerInputIndex = 0
                        self.simonSequence.append(Int.random(in: 0..<self.totalCards))
                        self.playSequence()
                    }
                }
            } else {
                // Wrong input in sequence
                HapticManager.shared.notification(type: .error)
                SoundManager.shared.play(.incorrect)
                loseLife()
                
                if lives > 0 {
                    isActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.playSequence()
                    }
                }
            }
        } else {
            // Standard Frenzy logic
            if activeIndices.contains(index) {
                currentScore += 1
                activeIndices.remove(index)
                
                // Sound and haptic on successful tile tap
                HapticManager.shared.impact(style: .light)
                SoundManager.shared.play(.correct)
                
                if activeIndices.isEmpty {
                    nextTurn()
                }
            } else {
                // Sound and haptic on incorrect tile tap
                HapticManager.shared.notification(type: .error)
                SoundManager.shared.play(.incorrect)
                loseLife()
            }
        }
    }
    
    private func nextTurn() {
        guard timeLeft > 0 else { return }
        
        isActive = false
        activeIndices.removeAll()
        
        var newIndices = Set<Int>()
        while newIndices.count < numActiveCards {
            newIndices.insert(Int.random(in: 0..<totalCards))
        }
        activeIndices = newIndices
        isActive = true
    }
    
    private func updateLevel(forElapsed elapsed: Int) {
        let oldLevel = level
        
        switch elapsed {
        case 0..<15:
            level = 1
            glowColor = .yellow
            interval = 1.5
        case 15..<30:
            level = 2
            glowColor = .green
            interval = 1.2
        case 30..<45:
            level = 3
            glowColor = .blue
            interval = 1.0
        default:
            level = 4
            glowColor = .pink
            interval = 0.8
        }
        
        if level != oldLevel {
            withAnimation {
                showLevelUp = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    self.showLevelUp = false
                }
            }
            nextTurn()
        }
    }
    
    private func loseLife() {
        guard lives > 0 else { return }
        lives -= 1
        if lives == 0 {
            gameEnded()
        }
    }
    
    private func gameEnded() {
        gameStarted = false
        timerStarted = false
        isPlayingSequence = false
        activeIndices.removeAll()
        isActive = false
        gameTimerSubscription?.cancel()
        
        var newHigh = false
        if currentScore > highScore {
            highScore = currentScore
            isPersonalBestSet = true
            newHigh = true
        }
        
        let name = self.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Guest" : self.playerName
        ScoreHistoryManager.saveScore(currentScore, playerName: name, for: "lightItUpHistory")
        GameSessionManager.shared.saveSession(gameMode: gameMode == .memory ? "Simon Says" : "Light It Up", score: currentScore)
        
        // Final sound and haptic feedback
        if newHigh {
            HapticManager.shared.notification(type: .success)
            SoundManager.shared.play(.victory)
        } else {
            HapticManager.shared.notification(type: .warning)
            SoundManager.shared.play(.incorrect)
        }
    }
    
    func cleanUp() {
        gameStarted = false
        timerStarted = false
        isPlayingSequence = false
        activeIndices.removeAll()
        isActive = false
        gameTimerSubscription?.cancel()
    }
}

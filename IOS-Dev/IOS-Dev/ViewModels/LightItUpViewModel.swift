import SwiftUI
import Combine

class LightItUpViewModel: ObservableObject {
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "tilesHighScore") {
        didSet {
            UserDefaults.standard.set(highScore, forKey: "tilesHighScore")
        }
    }
    
    @Published var currentScore = 0
    @Published var timeLeft = 60
    @Published var level = 1
    @Published var lives = 3
    @Published var showLevelUp = false
    @Published var activeIndices: Set<Int> = []
    @Published var isActive = false
    @Published var interval: Double = 1.5
    @Published var gameStarted = false
    @Published var elapsedTime = 0
    @Published var glowColor: Color = .yellow
    @Published var timerStarted = false
    
    private var gameTimerSubscription: AnyCancellable?
    
    var gridSize: (rows: Int, cols: Int) {
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
        
        startTimer()
        nextTurn()
    }
    
    func resetGame() {
        gameStarted = false
        timerStarted = false
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
                    self.timeLeft -= 1
                    self.elapsedTime += 1
                    self.updateLevel(forElapsed: self.elapsedTime)
                    if self.timeLeft == 0 {
                        self.gameEnded()
                    }
                }
            }
    }
    
    func tileTapped(index: Int) {
        if !timerStarted {
            timerStarted = true
        }
        guard gameStarted && isActive else { return }
        if activeIndices.contains(index) {
            currentScore += 1
            activeIndices.remove(index)
            if activeIndices.isEmpty {
                nextTurn()
            }
        } else {
            loseLife()
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
        activeIndices.removeAll()
        isActive = false
        gameTimerSubscription?.cancel()
        if currentScore > highScore {
            highScore = currentScore
        }
    }
    
    func cleanUp() {
        gameStarted = false
        timerStarted = false
        activeIndices.removeAll()
        isActive = false
        gameTimerSubscription?.cancel()
    }
}

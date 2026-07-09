import SwiftUI
import Combine

class QuizRushViewModel: ObservableObject {
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "quizRushHighScore") {
        didSet {
            UserDefaults.standard.set(highScore, forKey: "quizRushHighScore")
        }
    }
    
    @Published var playerName: String = UserDefaults.standard.string(forKey: "savedPlayerName") ?? "Guest" {
        didSet {
            UserDefaults.standard.set(playerName, forKey: "savedPlayerName")
        }
    }
    
    @Published var loadState: GameLoadState = .idle
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var maxStreak = 0
    @Published var questionTimeLeft = 15
    @Published var selectedCategoryID: Int? = nil
    @Published var isPersonalBestSet = false
    
    private var timerSubscription: AnyCancellable?
    
    func loadPlayerName() {
        playerName = UserDefaults.standard.string(forKey: "savedPlayerName") ?? "Guest"
    }
    
    @Published var selectedAnswerIndex: Int? = nil
    @Published var hasAnswered = false
    @Published var isGameOver = false
    @Published var isAdvancing = false
    
    func startQuestionTimer() {
        stopQuestionTimer()
        questionTimeLeft = 15
        
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.questionTimeLeft > 0 && !self.hasAnswered && !self.isGameOver {
                    self.questionTimeLeft -= 1
                    if self.questionTimeLeft == 0 {
                        self.questionTimeExpired()
                    }
                }
            }
    }
    
    func stopQuestionTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }
    
    private func questionTimeExpired() {
        guard !hasAnswered && !isAdvancing else { return }
        
        hasAnswered = true
        isAdvancing = true
        streak = 0
        score = max(0, score - 2)
        
        stopQuestionTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.advanceQuestion()
        }
    }
    
    func fetchQuestions() {
        loadState = .loading
        var urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
        if let categoryID = selectedCategoryID {
            urlString += "&category=\(categoryID)"
        }
        guard let url = URL(string: urlString) else {
            loadState = .failure("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.loadState = .failure(error.localizedDescription)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.loadState = .failure("No data received")
                }
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                    if decodedResponse.responseCode == 0 {
                        let questions = decodedResponse.results.map { raw in
                            let cleanQuestion = raw.question.htmlDecoded
                            let cleanCorrect = raw.correctAnswer.htmlDecoded
                            var cleanIncorrect = raw.incorrectAnswers.map { $0.htmlDecoded }
                            
                            cleanIncorrect.append(cleanCorrect)
                            let shuffled = cleanIncorrect.shuffled()
                            
                            return QuizQuestion(
                                category: raw.category.htmlDecoded,
                                question: cleanQuestion,
                                correctAnswer: cleanCorrect,
                                allAnswers: shuffled
                            )
                        }
                        
                        if questions.count == 10 {
                            self.loadState = .success(questions)
                            self.startQuestionTimer()
                        } else {
                            self.loadState = .failure("Received \(questions.count) questions instead of 10")
                        }
                    } else {
                        self.loadState = .failure("Server returned error code: \(decodedResponse.responseCode)")
                    }
                } catch {
                    self.loadState = .failure("Decoding error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func selectAnswer(index: Int, correctOption: String, answerText: String) {
        guard !hasAnswered && !isAdvancing else { return }
        
        stopQuestionTimer()
        
        selectedAnswerIndex = index
        hasAnswered = true
        isAdvancing = true
        
        if answerText == correctOption {
            streak += 1
            maxStreak = max(maxStreak, streak)
            let bonus = streak >= 3 ? 5 : 0
            score += 10 + bonus
            
            // Trigger correct feedback
            HapticManager.shared.impact(style: .light)
            SoundManager.shared.play(.correct)
        } else {
            streak = 0
            score = max(0, score - 2)
            
            // Trigger incorrect feedback
            HapticManager.shared.notification(type: .error)
            SoundManager.shared.play(.incorrect)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.advanceQuestion()
        }
    }
    
    func advanceQuestion() {
        if currentQuestionIndex < 9 {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedAnswerIndex = nil
                hasAnswered = false
                isAdvancing = false
                currentQuestionIndex += 1
            }
            startQuestionTimer()
        } else {
            stopQuestionTimer()
            
            var newHigh = false
            if score > highScore {
                highScore = score
                isPersonalBestSet = true
                newHigh = true
            }
            
            let name = self.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Guest" : self.playerName
            ScoreHistoryManager.saveScore(score, playerName: name, for: "quizRushHistory")
            GameSessionManager.shared.saveSession(gameMode: "Quiz Rush", score: score)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                isGameOver = true
            }
            
            // Play victory or incorrect final sounds
            if newHigh {
                HapticManager.shared.notification(type: .success)
                SoundManager.shared.play(.victory)
            } else {
                HapticManager.shared.notification(type: .warning)
                SoundManager.shared.play(.incorrect)
            }
        }
    }
    
    func resetGame() {
        stopQuestionTimer()
        currentQuestionIndex = 0
        score = 0
        streak = 0
        maxStreak = 0
        selectedAnswerIndex = nil
        hasAnswered = false
        isAdvancing = false
        isGameOver = false
        isPersonalBestSet = false
        fetchQuestions()
    }
    
    func cleanUp() {
        stopQuestionTimer()
    }
}

import SwiftUI
import Combine

class QuizRushViewModel: ObservableObject {
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "quizRushHighScore") {
        didSet {
            UserDefaults.standard.set(highScore, forKey: "quizRushHighScore")
        }
    }
    
    @Published var loadState: GameLoadState = .idle
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var maxStreak = 0
    @Published var selectedAnswerIndex: Int? = nil
    @Published var hasAnswered = false
    @Published var isGameOver = false
    @Published var isAdvancing = false
    
    func fetchQuestions() {
        loadState = .loading
        guard let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple") else {
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
        
        selectedAnswerIndex = index
        hasAnswered = true
        isAdvancing = true
        
        if answerText == correctOption {
            streak += 1
            maxStreak = max(maxStreak, streak)
            let bonus = streak >= 3 ? 5 : 0
            score += 10 + bonus
        } else {
            streak = 0
            score = max(0, score - 2)
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
        } else {
            if score > highScore {
                highScore = score
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                isGameOver = true
            }
        }
    }
    
    func resetGame() {
        currentQuestionIndex = 0
        score = 0
        streak = 0
        maxStreak = 0
        selectedAnswerIndex = nil
        hasAnswered = false
        isAdvancing = false
        isGameOver = false
        fetchQuestions()
    }
}

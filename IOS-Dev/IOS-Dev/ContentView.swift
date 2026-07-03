//
//  ContentView.swift
//  IOS-Dev
//
//  Created by Chethana Rowell on 2026-06-07.
//

import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeScreen()
        }
    }
}

struct HomeScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .teal.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 40) {
                Text("Game Zone")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                NavigationLink(destination: TapFrenzyGameView()) {
                    Text("Tap Frenzy")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                NavigationLink(destination: LightItUpGameView()) {
                    Text("Light It Up")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                NavigationLink(destination: QuizRushGameView()) {
                    Text("Quiz Rush")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.purple)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TapFrenzyGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("panicHighScore") private var highScore = 0
    
    @State private var pressCount = 0
    @State private var timeLeft = 10
    @State private var timerStarted = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 24) {
            Text("High Score: \(highScore)")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .padding(.top, 10)
            
            if timeLeft > 0 {
                Text("Pressed: \(pressCount)")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding(.top, 20)
                
                Button(action: {
                    if !timerStarted {
                        timerStarted = true
                    }
                    pressCount += 1
                }) {
                    Text("Press")
                        .font(.largeTitle)
                        .frame(width: 200, height: 200)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                        .shadow(color: .red.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                
                Text("Time left: \(timeLeft)")
                    .font(.title)
                    .foregroundStyle(.white)
                    .onReceive(timer) { _ in
                        if timeLeft > 0 && timerStarted {
                            timeLeft -= 1
                            if timeLeft == 0 {
                                if pressCount > highScore {
                                    highScore = pressCount
                                }
                            }
                        }
                    }
            } else {
                Text("Your pressed count: \(pressCount)")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding(.top, 50)
                
                Button("Replay") {
                    pressCount = 0
                    timeLeft = 10
                    timerStarted = false
                }
                .font(.title)
                .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: [.black, .red.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
    }
}

struct LightItUpGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("tilesHighScore") private var highScore = 0
    
    @State private var currentScore = 0
    @State private var timeLeft = 60
    @State private var level = 1
    
    // Removed old gridSize state, now controlled by updateLevel(forElapsed:)
    // @State private var gridSize = 2
    
    @State private var lives = 3
    @State private var showLevelUp = false
    
    @State private var activeIndices: Set<Int> = []
    @State private var isActive = false
    @State private var interval: Double = 1.5
    @State private var gameStarted = false
    
    @State private var elapsedTime: Int = 0
    
    @State private var glowColor: Color = .yellow
    
    @State private var timerStarted = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Computed gridSize and gridColumns based on level
    private var gridSize: (rows: Int, cols: Int) {
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
    
    private var totalCards: Int {
        gridSize.rows * gridSize.cols
    }
    
    private var numActiveCards: Int {
        level == 4 ? 2 : 1
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 15) {
                Text("High Score: \(highScore)")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Spacer()
                HStack(spacing: 6) {
                    ForEach(0..<lives, id: \.self) { _ in
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            if timeLeft > 0 && lives > 0 {
                HStack(spacing: 30) {
                    Text("Score: \(currentScore)")
                    Text("Time Left: \(timeLeft)s")
                    Text("Level: \(level)")
                }
                .font(.title3.bold())
                .foregroundStyle(.white)
                .padding(.bottom, 10)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: gridSize.cols), spacing: 15) {
                    ForEach(0..<totalCards, id: \.self) { index in
                        TileCard(isActive: activeIndices.contains(index), glowColor: glowColor) {
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
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding(.horizontal, 20)
                .onAppear {
                    startGame()
                }
                .onDisappear {
                    gameStarted = false
                    timerStarted = false
                    activeIndices.removeAll()
                    isActive = false
                }
                .overlay(
                    Group {
                        if showLevelUp {
                            glowColor
                                .opacity(0.4)
                                .ignoresSafeArea()
                                .transition(.opacity)
                        }
                    }
                )
            } else {
                VStack(spacing: 30) {
                    Text("Game Over")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    
                    if lives == 0 {
                        Text("You ran out of lives")
                            .font(.title2)
                            .foregroundStyle(.white)
                    } else if timeLeft == 0 && lives > 0 {
                        Text("Time's up!")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    
                    Text("Your Score: \(currentScore)")
                        .font(.title)
                        .foregroundStyle(.white)
                    
                    Button("Replay") {
                        resetGame()
                    }
                    .font(.title)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: [.black, .blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .onReceive(timer) { _ in
            if timerStarted && timeLeft > 0 && lives > 0 {
                timeLeft -= 1
                elapsedTime += 1
                updateLevel(forElapsed: elapsedTime)
                if timeLeft == 0 {
                    gameEnded()
                }
            }
        }
    }
    
    private func startGame() {
        resetGameVars()
        gameStarted = true
        timeLeft = 60
        lives = 3
        level = 1
        currentScore = 0
        elapsedTime = 0
        timerStarted = false
        
        updateLevel(forElapsed: 0)
        
        // Start first turn
        nextTurn()
    }
    
    private func resetGame() {
        gameStarted = false
        timerStarted = false
        activeIndices.removeAll()
        isActive = false
        
        startGame()
    }
    
    private func resetGameVars() {
        activeIndices.removeAll()
        isActive = false
    }
    
    private func nextTurn() {
        guard timeLeft > 0 else { return }
        
        isActive = false
        activeIndices.removeAll()
        
        // Select new active cards according to level's numActiveCards
        // Pick unique random indices
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
                    showLevelUp = false
                }
            }
            // Immediately call nextTurn to update active cards count and grid layout on level change
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
        if currentScore > highScore {
            highScore = currentScore
        }
    }
}

struct TileCard: View {
    var isActive: Bool
    var glowColor: Color
    var onTap: () -> Void
    
    @State private var animateHighlight = false
    
    var body: some View {
        Rectangle()
            .foregroundColor(isActive ? glowColor.opacity(0.8) : .gray.opacity(0.4))
            .cornerRadius(10)
            .shadow(color: isActive ? glowColor.opacity(animateHighlight ? 1 : 0) : .clear, radius: 12, x: 0, y: 0)
            .scaleEffect(isActive && animateHighlight ? 1.1 : 1.0)
            .animation(isActive ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: animateHighlight)
            .onChange(of: isActive) { newValue in
                if newValue {
                    animateHighlight = true
                } else {
                    animateHighlight = false
                }
            }
            .onTapGesture {
                onTap()
            }
    }
}

// MARK: - HTML Decoding Extension
extension String {
    var htmlDecoded: String {
        var result = self
        let entities = [
            "&quot;": "\"",
            "&#039;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&nbsp;": " ",
            "&rsquo;": "’",
            "&lsquo;": "‘",
            "&ldquo;": "“",
            "&rdquo;": "”",
            "&hellip;": "…",
            "&mdash;": "—",
            "&ndash;": "–",
            "&deg;": "°",
            "&aacute;": "á",
            "&eacute;": "é",
            "&iacute;": "í",
            "&oacute;": "ó",
            "&uacute;": "ú",
            "&ntilde;": "ñ",
            "&uuml;": "ü",
            "&Aacute;": "Á",
            "&Eacute;": "É",
            "&Iacute;": "Í",
            "&Oacute;": "Ó",
            "&Uacute;": "Ú",
            "&Ntilde;": "Ñ",
            "&Uuml;": "Ü"
        ]
        
        for (entity, unicode) in entities {
            result = result.replacingOccurrences(of: entity, with: unicode)
        }
        
        var finalResult = ""
        var currentIndex = result.startIndex
        
        while currentIndex < result.endIndex {
            if result[currentIndex...].hasPrefix("&#") {
                if let semicolonIndex = result[currentIndex...].firstIndex(of: ";") {
                    let startOfNumber = result.index(currentIndex, offsetBy: 2)
                    let numberString = String(result[startOfNumber..<semicolonIndex])
                    
                    var charCode: UInt32? = nil
                    if numberString.hasPrefix("x") || numberString.hasPrefix("X") {
                        let hexString = String(numberString.dropFirst())
                        charCode = UInt32(hexString, radix: 16)
                    } else {
                        charCode = UInt32(numberString, radix: 10)
                    }
                    
                    if let code = charCode, let unicodeChar = UnicodeScalar(code) {
                        finalResult.append(Character(unicodeChar))
                        currentIndex = result.index(after: semicolonIndex)
                        continue
                    }
                }
            }
            finalResult.append(result[currentIndex])
            currentIndex = result.index(after: currentIndex)
        }
        
        return finalResult
    }
}

// MARK: - Quiz Models
struct QuizQuestion: Identifiable {
    let id = UUID()
    let category: String
    let question: String
    let correctAnswer: String
    let allAnswers: [String]
}

struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [TriviaRawQuestion]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct TriviaRawQuestion: Codable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

// MARK: - Game Load State
enum GameLoadState {
    case idle
    case loading
    case success([QuizQuestion])
    case failure(String)
}

// MARK: - Quiz Rush Main View
struct QuizRushGameView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("quizRushHighScore") private var highScore = 0
    
    @State private var loadState: GameLoadState = .idle
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var streak = 0
    @State private var maxStreak = 0
    @State private var selectedAnswerIndex: Int? = nil
    @State private var hasAnswered = false
    @State private var isGameOver = false
    @State private var streakAnimationScale: CGFloat = 1.0
    @State private var isAdvancing = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .purple.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                switch loadState {
                case .idle:
                    Color.clear.onAppear {
                        fetchQuestions()
                    }
                case .loading:
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(2)
                        Text("Loading Questions...")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                case .success(let questions):
                    if isGameOver {
                        QuizGameOverView(score: score, maxStreak: maxStreak, highScore: highScore) {
                            resetGame()
                        }
                    } else {
                        let question = questions[currentQuestionIndex]
                        QuizGameplayView(
                            question: question,
                            questionNumber: currentQuestionIndex + 1,
                            totalQuestions: questions.count,
                            score: score,
                            streak: streak,
                            highScore: highScore,
                            selectedAnswerIndex: selectedAnswerIndex,
                            hasAnswered: hasAnswered,
                            streakAnimationScale: $streakAnimationScale,
                            onAnswerSelected: { index, answerText in
                                selectAnswer(index: index, correctOption: question.correctAnswer, answerText: answerText)
                            }
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                case .failure(let errorMessage):
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        Text("Connection Failed")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            fetchQuestions()
                        }) {
                            Text("Try Again")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.purple)
                                .cornerRadius(25)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
    }
    
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
            advanceQuestion()
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

// MARK: - Quiz Gameplay Screen
struct QuizGameplayView: View {
    let question: QuizQuestion
    let questionNumber: Int
    let totalQuestions: Int
    let score: Int
    let streak: Int
    let highScore: Int
    let selectedAnswerIndex: Int?
    let hasAnswered: Bool
    @Binding var streakAnimationScale: CGFloat
    let onAnswerSelected: (Int, String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Score: \(score)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("Best: \(highScore)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                
                if streak > 0 {
                    HStack(spacing: 4) {
                        Text("Streak: \(streak) 🔥")
                            .font(.headline.bold())
                            .foregroundColor(.orange)
                        if streak >= 3 {
                            Text("+5 Bonus!")
                                .font(.caption.bold())
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .scaleEffect(streakAnimationScale)
                    .onChange(of: streak) { newValue in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
                            streakAnimationScale = 1.3
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring()) {
                                streakAnimationScale = 1.0
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            ProgressView(value: Double(questionNumber), total: Double(totalQuestions))
                .tint(.purple)
                .background(Color.white.opacity(0.2))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                .cornerRadius(4)
                .padding(.horizontal, 20)
            
            Text("Question \(questionNumber) of \(totalQuestions)")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 12) {
                Text(question.category.uppercased())
                    .font(.caption.bold())
                    .foregroundColor(.purple)
                    .tracking(2)
                
                Text(question.question)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .purple.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            VStack(spacing: 12) {
                ForEach(0..<question.allAnswers.count, id: \.self) { index in
                    let answerText = question.allAnswers[index]
                    
                    QuizOptionButton(
                        text: answerText,
                        isSelected: selectedAnswerIndex == index,
                        isCorrect: answerText == question.correctAnswer,
                        hasAnswered: hasAnswered,
                        action: {
                            onAnswerSelected(index, answerText)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Option Button
struct QuizOptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let hasAnswered: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        if hasAnswered {
            if isCorrect {
                return Color.green.opacity(0.25)
            } else if isSelected {
                return Color.red.opacity(0.25)
            } else {
                return Color.white.opacity(0.05)
            }
        } else {
            return Color.white.opacity(0.12)
        }
    }
    
    private var strokeColor: Color {
        if hasAnswered {
            if isCorrect {
                return Color.green
            } else if isSelected {
                return Color.red
            } else {
                return Color.white.opacity(0.1)
            }
        } else {
            return Color.white.opacity(0.2)
        }
    }
    
    private var shadowColor: Color {
        if hasAnswered {
            if isCorrect {
                return Color.green.opacity(0.3)
            } else if isSelected {
                return Color.red.opacity(0.3)
            }
        }
        return Color.clear
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if hasAnswered {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 2)
            )
            .shadow(color: shadowColor, radius: 8, x: 0, y: 0)
        }
        .disabled(hasAnswered)
        .opacity(hasAnswered && !isCorrect && !isSelected ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.25), value: hasAnswered)
    }
}

// MARK: - Game Over Screen
struct QuizGameOverView: View {
    let score: Int
    let maxStreak: Int
    let highScore: Int
    let onReplay: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.4), radius: 15, x: 0, y: 5)
            
            Text("Quiz Finished!")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Round Score")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(score)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                
                Divider().background(Color.white.opacity(0.2))
                
                HStack {
                    Text("Max Streak")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(maxStreak) 🔥")
                        .font(.title3.bold())
                        .foregroundColor(.orange)
                }
                
                Divider().background(Color.white.opacity(0.2))
                
                HStack {
                    Text("Personal Best")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(highScore)")
                        .font(.title2.bold())
                        .foregroundColor(.purple)
                }
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal, 30)
            
            Button(action: onReplay) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise")
                    Text("Play Again")
                }
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(Color.purple)
                .cornerRadius(30)
                .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
            }
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

import SwiftUI

struct QuizRushGameView: View {
    @StateObject private var viewModel = QuizRushViewModel()
    @State private var streakAnimationScale: CGFloat = 1.0
    @State private var isGameStarted = false
    @State private var showHistory = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .purple.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                if !isGameStarted {
                    // Pre-game Lobby
                    VStack(spacing: 30) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.purple)
                            .shadow(color: .purple.opacity(0.4), radius: 15, x: 0, y: 5)
                            .padding(.top, 40)
                        
                        Text("Quiz Rush")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        // Instruction Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("HOW TO PLAY")
                                .font(.caption.bold())
                                .foregroundColor(.purple)
                                .tracking(2)
                            
                            Text("1. Answer 10 multiple-choice trivia questions.\n2. Correct answers add points & build a streak.\n3. Incorrect answers apply a small penalty.\n4. Consecutive streaks award bonus points!")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(6)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Player Name Input
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.purple)
                            TextField("", text: $viewModel.playerName, prompt: Text("Enter Player Name").foregroundColor(.white.opacity(0.4)))
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        
                        // Category Selection Dropdown
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.purple)
                            
                            Text("Genre:")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.headline)
                            
                            Spacer()
                            
                            Picker("Select Genre", selection: $viewModel.selectedCategoryID) {
                                ForEach(triviaCategories) { category in
                                    Text(category.name)
                                        .tag(category.id)
                                }
                            }
                            .tint(.purple)
                            .pickerStyle(.menu)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                        
                        // Difficulty Segmented Control
                        VStack(spacing: 8) {
                            Text("DIFFICULTY")
                                .font(.caption.bold())
                                .foregroundColor(.purple.opacity(0.8))
                                .tracking(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Picker("Difficulty", selection: $viewModel.selectedDifficulty) {
                                Text("Any").tag("any")
                                Text("Easy").tag("easy")
                                Text("Medium").tag("medium")
                                Text("Hard").tag("hard")
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal, 30)
                        
                        // Personal Best
                        VStack(spacing: 4) {
                            Text("Personal Best")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(viewModel.highScore)")
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                isGameStarted = true
                                viewModel.resetGame()
                            }) {
                                Text("Play")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.purple)
                                    .cornerRadius(30)
                                    .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal, 30)
                            
                            Button(action: {
                                showHistory = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "list.bullet.rectangle")
                                    Text("Score History")
                                }
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.vertical, 12)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                } else {
                    // Active Gameplay / Game Over
                    switch viewModel.loadState {
                    case .idle:
                        Color.clear.onAppear {
                            viewModel.fetchQuestions()
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
                        if viewModel.isGameOver {
                            QuizGameOverView(
                                score: viewModel.score,
                                maxStreak: viewModel.maxStreak,
                                highScore: viewModel.highScore,
                                onReplay: {
                                    viewModel.resetGame()
                                },
                                onLobby: {
                                    isGameStarted = false
                                }
                            )
                        } else {
                            let question = questions[viewModel.currentQuestionIndex]
                            QuizGameplayView(
                                question: question,
                                questionNumber: viewModel.currentQuestionIndex + 1,
                                totalQuestions: questions.count,
                                score: viewModel.score,
                                streak: viewModel.streak,
                                highScore: viewModel.highScore,
                                questionTimeLeft: viewModel.questionTimeLeft,
                                selectedAnswerIndex: viewModel.selectedAnswerIndex,
                                hasAnswered: viewModel.hasAnswered,
                                streakAnimationScale: $streakAnimationScale,
                                onAnswerSelected: { index, answerText in
                                    viewModel.selectAnswer(index: index, correctOption: question.correctAnswer, answerText: answerText)
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
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    viewModel.fetchQuestions()
                                }) {
                                    Text("Try Again")
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color.purple)
                                        .cornerRadius(25)
                                }
                                
                                Button(action: {
                                    isGameStarted = false
                                }) {
                                    Text("Lobby")
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(25)
                                }
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
            ConfettiView(isTriggered: $viewModel.isPersonalBestSet)
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showHistory) {
            ScoreHistorySheet(
                gameTitle: "Quiz Rush",
                history: ScoreHistoryManager.getHistory(for: "quizRushHistory"),
                highScore: viewModel.highScore,
                themeColor: .purple
            )
        }
        .onAppear {
            viewModel.loadPlayerName()
            TabBarManager.shared.isHidden = true
        }
        .onDisappear {
            viewModel.cleanUp()
            TabBarManager.shared.isHidden = false
        }
    }
}

struct QuizGameplayView: View {
    let question: QuizQuestion
    let questionNumber: Int
    let totalQuestions: Int
    let score: Int
    let streak: Int
    let highScore: Int
    let questionTimeLeft: Int
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
                    .onChange(of: streak) { _, _ in
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
            
            // Countdown timer visual bar
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(questionTimeLeft <= 5 ? .red : .purple)
                        .font(.footnote)
                    
                    Text("\(questionTimeLeft)s remaining")
                        .font(.footnote.bold())
                        .foregroundColor(questionTimeLeft <= 5 ? .red : .white.opacity(0.8))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(questionTimeLeft <= 5 ? Color.red : Color.purple)
                            .frame(width: geo.size.width * CGFloat(Double(questionTimeLeft) / 15.0), height: 6)
                            .shadow(color: (questionTimeLeft <= 5 ? Color.red : Color.purple).opacity(0.5), radius: 5, x: 0, y: 0)
                            .animation(.linear(duration: 0.25), value: questionTimeLeft)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, 20)
            
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

struct QuizGameOverView: View {
    let score: Int
    let maxStreak: Int
    let highScore: Int
    let onReplay: () -> Void
    let onLobby: () -> Void
    
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
            
            VStack(spacing: 12) {
                Button(action: onReplay) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                        Text("Play Again")
                    }
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.purple)
                    .cornerRadius(30)
                    .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                
                Button(action: onLobby) {
                    Text("Back to Lobby")
                        .font(.headline.bold())
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 30)
                
                ShareLink(item: "I just scored \(score) on Quiz Rush — beat that") {
                    Label("Share Score", systemImage: "square.and.arrow.up")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 30)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 40)
    }
}

struct TriviaCategory: Identifiable, Hashable {
    let id: Int?
    let name: String
}

let triviaCategories = [
    TriviaCategory(id: nil, name: "All Genres"),
    TriviaCategory(id: 9, name: "General Knowledge"),
    TriviaCategory(id: 11, name: "Film"),
    TriviaCategory(id: 12, name: "Music"),
    TriviaCategory(id: 14, name: "Television"),
    TriviaCategory(id: 15, name: "Video Games"),
    TriviaCategory(id: 17, name: "Science & Nature"),
    TriviaCategory(id: 18, name: "Computers"),
    TriviaCategory(id: 21, name: "Sports"),
    TriviaCategory(id: 22, name: "Geography"),
    TriviaCategory(id: 23, name: "History"),
    TriviaCategory(id: 24, name: "Politics"),
    TriviaCategory(id: 27, name: "Animals"),
]

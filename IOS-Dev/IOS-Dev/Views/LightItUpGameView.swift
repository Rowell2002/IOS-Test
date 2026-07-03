import SwiftUI

struct LightItUpGameView: View {
    @StateObject private var viewModel = LightItUpViewModel()
    @State private var isGameStarted = false
    @State private var showHistory = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .blue.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                if !isGameStarted {
                    // Pre-game Lobby
                    VStack(spacing: 30) {
                        Image(systemName: "squareshape.squareshape.dotted")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                            .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 5)
                            .padding(.top, 40)
                        
                        Text("Light It Up")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        // Instruction Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("HOW TO PLAY")
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                                .tracking(2)
                            
                            Text("1. Tap the highlighted glowing tiles.\n2. Tap incorrect cards, and you lose a life!\n3. Beat the levels before time runs out!")
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
                                .foregroundColor(.blue)
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
                            }) {
                                Text("Play")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.blue)
                                    .cornerRadius(30)
                                    .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
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
                    // Active Gameplay
                    VStack(spacing: 16) {
                        HStack(spacing: 15) {
                            Text("High Score: \(viewModel.highScore)")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                            Spacer()
                            HStack(spacing: 6) {
                                ForEach(0..<viewModel.lives, id: \.self) { _ in
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        if viewModel.timeLeft > 0 && viewModel.lives > 0 {
                            HStack(spacing: 30) {
                                Text("Score: \(viewModel.currentScore)")
                                Text("Time Left: \(viewModel.timeLeft)s")
                                Text("Level: \(viewModel.level)")
                            }
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .padding(.bottom, 10)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: viewModel.gridSize.cols), spacing: 15) {
                                ForEach(0..<viewModel.totalCards, id: \.self) { index in
                                    TileCard(isActive: viewModel.activeIndices.contains(index), glowColor: viewModel.glowColor) {
                                        viewModel.tileTapped(index: index)
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                }
                            }
                            .padding(.horizontal, 20)
                            .onAppear {
                                viewModel.startGame()
                            }
                            .overlay(
                                Group {
                                    if viewModel.showLevelUp {
                                        viewModel.glowColor
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
                                
                                if viewModel.lives == 0 {
                                    Text("You ran out of lives")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                } else if viewModel.timeLeft == 0 && viewModel.lives > 0 {
                                    Text("Time's up!")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                }
                                
                                Text("Your Score: \(viewModel.currentScore)")
                                    .font(.title)
                                    .foregroundStyle(.white)
                                
                                HStack(spacing: 20) {
                                    Button("Replay") {
                                        viewModel.resetGame()
                                    }
                                    .font(.title3.bold())
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                    
                                    Button("Lobby") {
                                        viewModel.cleanUp()
                                        isGameStarted = false
                                    }
                                    .font(.title3.bold())
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.15))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        Spacer()
                    }
                    .onDisappear {
                        viewModel.cleanUp()
                    }
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            ScoreHistorySheet(
                gameTitle: "Light It Up",
                history: ScoreHistoryManager.getHistory(for: "lightItUpHistory"),
                highScore: viewModel.highScore,
                themeColor: .blue
            )
        }
        .onAppear {
            viewModel.loadPlayerName()
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
            .onChange(of: isActive) { _, newValue in
                animateHighlight = newValue
            }
            .onTapGesture {
                onTap()
            }
    }
}

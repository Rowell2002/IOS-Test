import SwiftUI

struct LightItUpGameView: View {
    @StateObject private var viewModel = LightItUpViewModel()
    
    var body: some View {
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
                .onDisappear {
                    viewModel.cleanUp()
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
                    
                    Button("Replay") {
                        viewModel.resetGame()
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

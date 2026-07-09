import SwiftUI

struct TapFrenzyGameView: View {
    @StateObject private var viewModel = TapFrenzyViewModel()
    @State private var isGameStarted = false
    @State private var showHistory = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .red.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                if !isGameStarted {
                    // Pre-game Lobby
                    VStack(spacing: 30) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.red)
                            .shadow(color: .red.opacity(0.4), radius: 15, x: 0, y: 5)
                            .padding(.top, 40)
                        
                        Text("Tap Frenzy")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        // Instruction Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("HOW TO PLAY")
                                .font(.caption.bold())
                                .foregroundColor(.red)
                                .tracking(2)
                            
                            Text("1. Tap the giant button as fast as you can.\n2. You have exactly 10 seconds.\n3. Rack up the highest score possible!")
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
                                .foregroundColor(.red)
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
                                    .background(Color.red)
                                    .cornerRadius(30)
                                    .shadow(color: .red.opacity(0.4), radius: 10, x: 0, y: 5)
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
                    VStack(spacing: 24) {
                        Text("High Score: \(viewModel.highScore)")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .padding(.top, 10)
                        
                        if viewModel.timeLeft > 0 {
                            Text("Pressed: \(viewModel.pressCount)")
                                .font(.title)
                                .foregroundStyle(.white)
                                .padding(.top, 20)
                            
                            Button(action: {
                                viewModel.buttonPressed()
                            }) {
                                Text("Press")
                                    .font(.largeTitle)
                                    .frame(width: 200, height: 200)
                                    .background(Color.red)
                                    .foregroundStyle(.white)
                                    .clipShape(Circle())
                                    .shadow(color: .red.opacity(0.5), radius: 20, x: 0, y: 10)
                            }
                            
                            Text("Time left: \(viewModel.timeLeft)")
                                .font(.title)
                                .foregroundStyle(.white)
                        } else {
                            Text("Your pressed count: \(viewModel.pressCount)")
                                .font(.title)
                                .foregroundStyle(.white)
                                .padding(.top, 50)
                            
                            HStack(spacing: 20) {
                                Button("Replay") {
                                    viewModel.replay()
                                }
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .cornerRadius(20)
                                
                                Button("Lobby") {
                                    viewModel.replay()
                                    isGameStarted = false
                                }
                                .font(.title3.bold())
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(20)
                            }
                            
                            ShareLink(item: "I just scored \(viewModel.pressCount) on Tap Frenzy — beat that") {
                                Label("Share Score", systemImage: "square.and.arrow.up")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.2))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                    )
                            }
                            .padding(.top, 12)
                        }
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            ScoreHistorySheet(
                gameTitle: "Tap Frenzy",
                history: ScoreHistoryManager.getHistory(for: "tapFrenzyHistory"),
                highScore: viewModel.highScore,
                themeColor: .red
            )
        }
        .onDisappear {
            viewModel.cancelTimer()
            TabBarManager.shared.isHidden = false
        }
        .onAppear {
            viewModel.loadPlayerName()
            TabBarManager.shared.isHidden = true
        }
    }
}

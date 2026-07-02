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

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

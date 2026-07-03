import SwiftUI

struct HomeScreen: View {
    @AppStorage("panicHighScore") private var tapHighScore = 0
    @AppStorage("tilesHighScore") private var tilesHighScore = 0
    @AppStorage("quizRushHighScore") private var quizHighScore = 0
    
    var body: some View {
        ZStack {
            // Background Layer: Sleek Dark theme with radial color glows
            Color.black.ignoresSafeArea()
            
            RadialGradient(colors: [.purple.opacity(0.25), .clear], center: .topTrailing, startRadius: 10, endRadius: 350)
                .ignoresSafeArea()
            
            RadialGradient(colors: [.blue.opacity(0.2), .clear], center: .bottomLeading, startRadius: 10, endRadius: 450)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("GAME ZONE")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                            .tracking(3)
                        
                        Text("Choose Your Challenge")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // Games Cards Container
                    VStack(spacing: 20) {
                        GameCard(
                            title: "Tap Frenzy",
                            description: "Test your tapping speed and mash the button before the 10-second timer runs out!",
                            iconName: "hand.tap.fill",
                            highScore: tapHighScore,
                            themeColor: .red,
                            destination: TapFrenzyGameView()
                        )
                        
                        GameCard(
                            title: "Light It Up",
                            description: "A fast-paced grid memory game. Hit the glowing active cards without running out of lives.",
                            iconName: "squareshape.squareshape.dotted",
                            highScore: tilesHighScore,
                            themeColor: .blue,
                            destination: LightItUpGameView()
                        )
                        
                        GameCard(
                            title: "Quiz Rush",
                            description: "A trivia race against 10 random questions from the web. Maintain correct streaks for score multipliers!",
                            iconName: "lightbulb.fill",
                            highScore: quizHighScore,
                            themeColor: .purple,
                            destination: QuizRushGameView()
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true) // Hides navigation bar title since we build a custom styled header
    }
}

struct GameCard<Destination: View>: View {
    let title: String
    let description: String
    let iconName: String
    let highScore: Int
    let themeColor: Color
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 18) {
                // Glow Icon Block
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeColor.opacity(0.35), lineWidth: 1)
                        )
                    
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundColor(themeColor)
                        .shadow(color: themeColor.opacity(0.4), radius: 5, x: 0, y: 0)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text("High Score: \(highScore)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.35))
            }
            .padding(18)
            .background(.ultraThinMaterial)
            .cornerRadius(22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
    }
}

import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var sessionManager = GameSessionManager.shared
    
    @AppStorage("panicHighScore") private var tapHighScore = 0
    @AppStorage("tilesHighScore") private var tilesHighScore = 0
    @AppStorage("quizRushHighScore") private var quizHighScore = 0
    
    var body: some View {
        ZStack {
            // Dark elegant background
            Color.black.ignoresSafeArea()
            
            RadialGradient(colors: [.purple.opacity(0.15), .clear], center: .topTrailing, startRadius: 10, endRadius: 350)
                .ignoresSafeArea()
            RadialGradient(colors: [.blue.opacity(0.12), .clear], center: .bottomLeading, startRadius: 10, endRadius: 450)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PERFORMANCE")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                            .tracking(3)
                        
                        Text("Stats & Analytics")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // Totals Section
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatSummaryCard(
                            title: "Total Games",
                            value: "\(sessionManager.sessions.count)",
                            icon: "gamecontroller.fill",
                            color: .blue
                        )
                        
                        StatSummaryCard(
                            title: "Total Points",
                            value: "\(sessionManager.sessions.reduce(0) { $0 + $1.score })",
                            icon: "sum",
                            color: .purple
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Personal Bests Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personal Bests")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            PersonalBestRow(game: "Tap Frenzy", score: tapHighScore, icon: "hand.tap.fill", color: .green)
                            PersonalBestRow(game: "Light It Up", score: tilesHighScore, icon: "squareshape.squareshape.dotted", color: .blue)
                            PersonalBestRow(game: "Quiz Rush", score: quizHighScore, icon: "lightbulb.fill", color: .red)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Charts Section (Bar Chart per Mode)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Performance Progress")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 20) {
                            GameProgressChart(title: "Tap Frenzy", sessions: sessionManager.sessions.filter { $0.gameMode == "Tap Frenzy" }, themeColor: .green)
                            GameProgressChart(title: "Light It Up", sessions: sessionManager.sessions.filter { $0.gameMode == "Light It Up" }, themeColor: .blue)
                            GameProgressChart(title: "Quiz Rush", sessions: sessionManager.sessions.filter { $0.gameMode == "Quiz Rush" }, themeColor: .red)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Recent Sessions Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Sessions")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        if sessionManager.sessions.isEmpty {
                            Text("No sessions recorded yet. Play some games first!")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.45))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(sessionManager.sessions.prefix(5)) { session in
                                    RecentSessionRow(session: session)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            sessionManager.loadSessions()
        }
    }
}

struct StatSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PersonalBestRow: View {
    let game: String
    let score: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(game)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("High Score")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Text("\(score)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
        }
        .padding(12)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct GameProgressChart: View {
    let title: String
    let sessions: [GameSession]
    let themeColor: Color
    
    // We display the last 7 sessions in chronological order
    var chartData: [GameSession] {
        Array(sessions.prefix(7).reversed())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            
            if chartData.isEmpty {
                HStack {
                    Spacer()
                    Text("No history. Complete a game to see data!")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.35))
                        .padding(.vertical, 30)
                    Spacer()
                }
            } else {
                Chart {
                    ForEach(Array(chartData.enumerated()), id: \.element.id) { index, session in
                        BarMark(
                            x: .value("Game #", "\(index + 1)"),
                            y: .value("Score", session.score)
                        )
                        .foregroundStyle(themeColor.gradient)
                        .cornerRadius(6)
                    }
                }
                .frame(height: 120)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                            .foregroundStyle(Color.white.opacity(0.06))
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct RecentSessionRow: View {
    let session: GameSession
    
    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: session.date, relativeTo: Date())
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.gameMode)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(relativeTime)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if session.latitude != nil && session.longitude != nil {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 12))
                }
                
                Text("Score: \(session.score)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
}

#Preview {
    StatsView()
}

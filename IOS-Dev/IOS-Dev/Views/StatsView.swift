import SwiftUI
import Charts

struct LeaderboardPlayer: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let avatar: String
    let score: Int
    let isUser: Bool
}

struct StatsView: View {
    @ObservedObject var sessionManager = GameSessionManager.shared
    
    @State private var selectedGameFilter: String = "All"
    
    var tapHighScore: Int {
        let key = AuthManager.shared.currentUser.map { "panicHighScore_\($0.email)" } ?? "panicHighScore"
        return UserDefaults.standard.integer(forKey: key)
    }
    var tilesHighScore: Int {
        let key = AuthManager.shared.currentUser.map { "tilesHighScore_\($0.email)" } ?? "tilesHighScore"
        return UserDefaults.standard.integer(forKey: key)
    }
    var quizHighScore: Int {
        let key = AuthManager.shared.currentUser.map { "quizRushHighScore_\($0.email)" } ?? "quizRushHighScore"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    // Scoped models for Multi-Player History
    struct PlayerGameSession: Identifiable {
        let id = UUID()
        let playerName: String
        let playerAvatar: String
        let gameMode: String
        let score: Int
        let date: Date
    }
    
    var allPlayersSessions: [PlayerGameSession] {
        var allSessions: [PlayerGameSession] = []
        let accounts = AuthManager.shared.getAllAccounts()
        
        for account in accounts {
            let key = "gameSessions_\(account.email)"
            if let data = UserDefaults.standard.data(forKey: key),
               let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
                for session in decoded {
                    allSessions.append(PlayerGameSession(
                        playerName: account.fullName,
                        playerAvatar: account.avatar ?? "👾",
                        gameMode: session.gameMode,
                        score: session.score,
                        date: session.date
                    ))
                }
            }
        }
        
        if let currentUser = AuthManager.shared.currentUser, !accounts.contains(where: { $0.email == currentUser.email }) {
            let key = "gameSessions_\(currentUser.email)"
            if let data = UserDefaults.standard.data(forKey: key),
               let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
                for session in decoded {
                    allSessions.append(PlayerGameSession(
                        playerName: currentUser.fullName,
                        playerAvatar: currentUser.avatar ?? "👾",
                        gameMode: session.gameMode,
                        score: session.score,
                        date: session.date
                    ))
                }
            }
        }
        
        return allSessions.sorted(by: { $0.date > $1.date })
    }
    
    var filteredAllPlayersSessions: [PlayerGameSession] {
        if selectedGameFilter == "All" {
            return allPlayersSessions
        }
        return allPlayersSessions.filter { $0.gameMode == selectedGameFilter }
    }
    
    // User total score
    var userTotalPoints: Int {
        sessionManager.sessions.reduce(0) { $0 + $1.score }
    }
    
    // Leaderboards list combining player with mock global list, sorted descending
    var leaderboardPlayers: [LeaderboardPlayer] {
        let accounts = AuthManager.shared.getAllAccounts()
        var players: [LeaderboardPlayer] = []
        var processedEmails = Set<String>()
        
        for account in accounts {
            let score = totalPoints(for: account.email)
            let isCurrent = account.email == (AuthManager.shared.currentUser?.email ?? "")
            
            players.append(LeaderboardPlayer(
                name: account.fullName,
                avatar: account.avatar ?? "👾",
                score: score,
                isUser: isCurrent
            ))
            processedEmails.insert(account.email)
        }
        
        if let currentUser = AuthManager.shared.currentUser, !processedEmails.contains(currentUser.email) {
            let score = totalPoints(for: currentUser.email)
            players.append(LeaderboardPlayer(
                name: currentUser.fullName,
                avatar: currentUser.avatar ?? "👾",
                score: score,
                isUser: true
            ))
        }
        
        return players.sorted(by: { $0.score > $1.score })
    }
    
    private func totalPoints(for email: String) -> Int {
        let key = "gameSessions_\(email)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([GameSession].self, from: data) else {
            return 0
        }
        return decoded.reduce(0) { $0 + $1.score }
    }
    
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
                            .foregroundColor(Color(red: 220/255, green: 170/255, blue: 255/255))
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
                            value: "\(userTotalPoints)",
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
                    
                    // Global Leaderboard Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Global Leaderboard")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 10) {
                            ForEach(Array(leaderboardPlayers.enumerated()), id: \.element.id) { index, player in
                                LeaderboardRow(rank: index + 1, player: player)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // All Players' Score History Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All Players' Score History")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        // Game mode picker chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(["All", "Tap Frenzy", "Light It Up", "Quiz Rush"], id: \.self) { filter in
                                    Button(action: {
                                        selectedGameFilter = filter
                                        HapticManager.shared.impact(style: .light)
                                    }) {
                                        Text(filter)
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(selectedGameFilter == filter ? Color.black : Color.white.opacity(0.8))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedGameFilter == filter ? Color.purple : Color.white.opacity(0.08))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedGameFilter == filter ? Color.purple : Color.white.opacity(0.12), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 4)
                        
                        if filteredAllPlayersSessions.isEmpty {
                            Text("No history recorded for this game mode.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.45))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(filteredAllPlayersSessions.prefix(15)) { session in
                                    AllPlayersSessionRow(session: session)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.bottom, 120) // safety space for custom tab bar
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

// MARK: - Leaderboard Row Component
struct LeaderboardRow: View {
    let rank: Int
    let player: LeaderboardPlayer
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(rankColor(rank).opacity(0.18))
                    .frame(width: 32, height: 32)
                
                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(rankColor(rank))
            }
            
            Text(player.avatar)
                .font(.system(size: 24))
            
            Text(player.name)
                .font(.system(size: 15, weight: player.isUser ? .heavy : .bold, design: .rounded))
                .foregroundColor(player.isUser ? Color(red: 220/255, green: 180/255, blue: 255/255) : .white)
            
            Spacer()
            
            Text("\(player.score) pts")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(player.isUser ? Color(red: 220/255, green: 180/255, blue: 255/255) : .white.opacity(0.6))
        }
        .padding(14)
        .background(player.isUser ? Color.purple.opacity(0.12) : Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(player.isUser ? Color.purple.opacity(0.5) : Color.white.opacity(0.08), lineWidth: player.isUser ? 1.5 : 1)
        )
        .shadow(color: player.isUser ? .purple.opacity(0.15) : .clear, radius: 6, x: 0, y: 3)
    }
    
    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1:  return .yellow
        case 2:  return Color(white: 0.82)
        case 3:  return Color(red: 0.8, green: 0.52, blue: 0.32)
        default: return .white.opacity(0.55)
        }
    }
}

// MARK: - All Players Session Row Component
struct AllPlayersSessionRow: View {
    let session: StatsView.PlayerGameSession
    
    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: session.date, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(session.playerAvatar)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(session.playerName)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(session.gameMode)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(colorForMode(session.gameMode))
                        .cornerRadius(4)
                }
                
                Text(relativeTime)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Text("Score: \(session.score)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
    
    private func colorForMode(_ mode: String) -> Color {
        switch mode {
        case "Tap Frenzy": return .green
        case "Light It Up", "Simon Says": return .blue
        case "Quiz Rush": return .red
        default: return .purple
        }
    }
}

#Preview {
    StatsView()
}

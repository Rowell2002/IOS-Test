import SwiftUI
import MapKit

struct MapView: View {
    struct MapSession: Identifiable, Hashable {
        let id: UUID
        let gameMode: String
        let score: Int
        let date: Date
        let latitude: Double
        let longitude: Double
        let playerName: String
        let playerAvatar: String
        let isCurrentUser: Bool
    }
    
    @ObservedObject var sessionManager = GameSessionManager.shared
    @State private var selectedSession: MapSession? = nil
    @State private var position: MapCameraPosition = .automatic
    
    // Filter State
    @State private var selectedFilter: String = "All"
    
    var sessionsWithLocation: [MapSession] {
        var allMapSessions: [MapSession] = []
        let accounts = AuthManager.shared.getAllAccounts()
        let currentUser = AuthManager.shared.currentUser
        
        for account in accounts {
            let key = "gameSessions_\(account.email)"
            if let data = UserDefaults.standard.data(forKey: key),
               let sessions = try? JSONDecoder().decode([GameSession].self, from: data) {
                for s in sessions {
                    if let lat = s.latitude, let lon = s.longitude {
                        allMapSessions.append(MapSession(
                            id: s.id,
                            gameMode: s.gameMode,
                            score: s.score,
                            date: s.date,
                            latitude: lat,
                            longitude: lon,
                            playerName: account.fullName,
                            playerAvatar: account.avatar ?? "👾",
                            isCurrentUser: account.email == currentUser?.email
                        ))
                    }
                }
            }
        }
        
        if let currentUser = currentUser, !accounts.contains(where: { $0.email == currentUser.email }) {
            let key = "gameSessions_\(currentUser.email)"
            if let data = UserDefaults.standard.data(forKey: key),
               let sessions = try? JSONDecoder().decode([GameSession].self, from: data) {
                for s in sessions {
                    if let lat = s.latitude, let lon = s.longitude {
                        allMapSessions.append(MapSession(
                            id: s.id,
                            gameMode: s.gameMode,
                            score: s.score,
                            date: s.date,
                            latitude: lat,
                            longitude: lon,
                            playerName: currentUser.fullName,
                            playerAvatar: currentUser.avatar ?? "👾",
                            isCurrentUser: true
                        ))
                    }
                }
            }
        }
        
        return allMapSessions
    }
    
    var filteredSessions: [MapSession] {
        let items = sessionsWithLocation
        if selectedFilter == "All" {
            return items
        }
        return items.filter { $0.gameMode == selectedFilter }
    }
    
    // Find the session with the absolute highest score
    var highestScoreSession: MapSession? {
        sessionsWithLocation.max(by: { $0.score < $1.score })
    }
    
    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedSession) {
                ForEach(filteredSessions) { session in
                    let isHighest = session.id == highestScoreSession?.id
                    
                    Annotation(session.gameMode, coordinate: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)) {
                        VStack(spacing: 0) {
                            HStack(spacing: 4) {
                                if isHighest {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(Color(red: 45/255, green: 20/255, blue: 70/255))
                                        .font(.system(size: 11, weight: .bold))
                                }
                                Text("\(session.score)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(isHighest ? Color(red: 45/255, green: 20/255, blue: 70/255) : .white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                isHighest
                                ? LinearGradient(colors: [.yellow, Color(red: 1.0, green: 0.8, blue: 0.1)], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [colorForMode(session.gameMode), colorForMode(session.gameMode)], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(8)
                            .shadow(color: isHighest ? .yellow.opacity(0.6) : .black.opacity(0.3), radius: isHighest ? 6 : 2)
                            .scaleEffect(isHighest ? 1.15 : 1.0)
                            
                            Image(systemName: "triangle.fill")
                                .resizable()
                                .frame(width: 8, height: 6)
                                .foregroundColor(isHighest ? Color(red: 1.0, green: 0.8, blue: 0.1) : colorForMode(session.gameMode))
                                .rotationEffect(.degrees(180))
                                .offset(y: -2)
                        }
                        .scaleEffect(selectedSession?.id == session.id ? 1.2 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: selectedSession)
                    }
                    .tag(session)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            
            // UI Overlay
            VStack {
                // Integrated Header & Filters Card
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("GAME MAP")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                            .tracking(3)
                        
                        Text("Session Pins")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    // Sliding Filters Control inside Card
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["All", "Tap Frenzy", "Light It Up", "Quiz Rush"], id: \.self) { filter in
                                Button(action: {
                                    selectedFilter = filter
                                    HapticManager.shared.impact(style: .light)
                                }) {
                                    Text(filter)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(selectedFilter == filter ? Color.black : Color.white.opacity(0.8))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedFilter == filter ? Color.purple : Color.white.opacity(0.08))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedFilter == filter ? Color.purple : Color.white.opacity(0.12), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 4)
                
                Spacer()
                
                // Pin Detail Card
                if let session = selectedSession {
                    sessionDetailCard(session: session)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.bottom, 12)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            sessionManager.loadSessions()
            LocationManager.shared.requestPermission()
            LocationManager.shared.startUpdating()
            updateCameraPosition()
        }
    }
    
    private func updateCameraPosition() {
        if let lastSession = sessionsWithLocation.first {
            let coordinate = CLLocationCoordinate2D(latitude: lastSession.latitude, longitude: lastSession.longitude)
            position = .camera(MapCamera(centerCoordinate: coordinate, distance: 5000))
        } else {
            // Default position (San Francisco / Apple HQ)
            position = .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.009020), distance: 80000))
        }
    }
    
    private func colorForMode(_ mode: String) -> Color {
        switch mode {
        case "Tap Frenzy": return .green
        case "Light It Up": return .blue
        case "Quiz Rush": return .red
        default: return .purple
        }
    }
    
    private func iconForMode(_ mode: String) -> String {
        switch mode {
        case "Tap Frenzy": return "hand.tap.fill"
        case "Light It Up": return "squareshape.squareshape.dotted"
        case "Quiz Rush": return "lightbulb.fill"
        default: return "gamecontroller.fill"
        }
    }
    
    private func sessionDetailCard(session: MapSession) -> some View {
        let isHighest = session.id == highestScoreSession?.id
        
        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isHighest ? Color.yellow.opacity(0.15) : colorForMode(session.gameMode).opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Text(session.playerAvatar)
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(session.gameMode)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if isHighest {
                        Text("PB 👑")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow)
                            .cornerRadius(4)
                    }
                }
                
                Text("Played by \(session.playerName)")
                    .font(.caption.bold())
                    .foregroundColor(session.isCurrentUser ? Color(red: 220/255, green: 170/255, blue: 255/255) : .white.opacity(0.6))
                
                HStack(spacing: 6) {
                    Text(session.date, style: .date)
                    Text("•")
                    Text(session.date, style: .time)
                }
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(isHighest ? .yellow : colorForMode(session.gameMode))
                Text("Score")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Button(action: {
                withAnimation {
                    selectedSession = nil
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.3))
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isHighest ? Color.yellow.opacity(0.4) : Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.bottom, 80) // Leave space for custom tab bar
        .shadow(color: isHighest ? .yellow.opacity(0.1) : .black.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    MapView()
}

import Foundation
import CoreLocation
import Combine

class GameSessionManager: ObservableObject {
    static let shared = GameSessionManager()
    
    @Published var sessions: [GameSession] = []
    
    init() {
        loadSessions()
    }
    
    private var scopedSessionsKey: String {
        if let currentUser = AuthManager.shared.currentUser {
            return "gameSessions_\(currentUser.email)"
        }
        return "gameSessions"
    }
    
    func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: scopedSessionsKey),
              let decoded = try? JSONDecoder().decode([GameSession].self, from: data) else {
            self.sessions = []
            return
        }
        self.sessions = decoded
    }
    
    func saveSession(gameMode: String, score: Int) {
        // Request/ensure location updating is active so we capture location
        LocationManager.shared.startUpdating()
        
        let location = LocationManager.shared.lastLocation
        
        // Simulators sometimes don't have location yet if startUpdating was just called.
        let lat = location?.coordinate.latitude
        let lon = location?.coordinate.longitude
        
        let session = GameSession(
            gameMode: gameMode,
            score: score,
            latitude: lat,
            longitude: lon
        )
        
        sessions.insert(session, at: 0)
        
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: scopedSessionsKey)
        }
    }
    
    func resetAll() {
        sessions.removeAll()
        UserDefaults.standard.removeObject(forKey: scopedSessionsKey)
        
        if let currentUser = AuthManager.shared.currentUser {
            let email = currentUser.email
            UserDefaults.standard.set(0, forKey: "panicHighScore_\(email)")
            UserDefaults.standard.set(0, forKey: "tilesHighScore_\(email)")
            UserDefaults.standard.set(0, forKey: "quizRushHighScore_\(email)")
            
            UserDefaults.standard.removeObject(forKey: "tapFrenzyHistory_\(email)")
            UserDefaults.standard.removeObject(forKey: "lightItUpHistory_\(email)")
            UserDefaults.standard.removeObject(forKey: "quizRushHistory_\(email)")
        } else {
            // Also reset high scores
            UserDefaults.standard.set(0, forKey: "panicHighScore")
            UserDefaults.standard.set(0, forKey: "tilesHighScore")
            UserDefaults.standard.set(0, forKey: "quizRushHighScore")
            
            // Also reset individual game histories if any
            UserDefaults.standard.removeObject(forKey: "tapFrenzyHistory")
            UserDefaults.standard.removeObject(forKey: "lightItUpHistory")
            UserDefaults.standard.removeObject(forKey: "quizRushHistory")
        }
        
        // Reset daily challenge played date
        DailyChallengeHelper.resetDailyChallenge()
    }
}

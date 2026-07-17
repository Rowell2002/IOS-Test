import Foundation

struct ScoreHistoryManager {
    static func getHistory(for gameKey: String) -> [ScoreEntry] {
        let key = scopedKey(for: gameKey)
        guard let data = UserDefaults.standard.data(forKey: key),
              let history = try? JSONDecoder().decode([ScoreEntry].self, from: data) else {
            return []
        }
        return history
    }
    
    static func saveScore(_ score: Int, playerName: String, for gameKey: String) {
        let key = scopedKey(for: gameKey)
        var history = getHistory(for: gameKey)
        let entry = ScoreEntry(score: score, date: Date(), playerName: playerName)
        history.insert(entry, at: 0)
        
        // Limit to last 20 entries
        if history.count > 20 {
            history = Array(history.prefix(20))
        }
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private static func scopedKey(for baseKey: String) -> String {
        if let currentUser = AuthManager.shared.currentUser {
            return "\(baseKey)_\(currentUser.email)"
        }
        return baseKey
    }
}

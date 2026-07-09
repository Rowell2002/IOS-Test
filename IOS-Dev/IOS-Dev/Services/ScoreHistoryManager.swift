import Foundation

struct ScoreHistoryManager {
    static func getHistory(for gameKey: String) -> [ScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: gameKey),
              let history = try? JSONDecoder().decode([ScoreEntry].self, from: data) else {
            return []
        }
        return history
    }
    
    static func saveScore(_ score: Int, playerName: String, for gameKey: String) {
        var history = getHistory(for: gameKey)
        let entry = ScoreEntry(score: score, date: Date(), playerName: playerName)
        history.insert(entry, at: 0)
        
        // Limit to last 20 entries
        if history.count > 20 {
            history = Array(history.prefix(20))
        }
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: gameKey)
        }
    }
}

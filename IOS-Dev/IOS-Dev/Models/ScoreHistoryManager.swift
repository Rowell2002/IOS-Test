import Foundation

struct ScoreEntry: Codable, Identifiable {
    let id: UUID
    let score: Int
    let date: Date
    
    init(id: UUID = UUID(), score: Int, date: Date = Date()) {
        self.id = id
        self.score = score
        self.date = date
    }
}

struct ScoreHistoryManager {
    static func getHistory(for gameKey: String) -> [ScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: gameKey),
              let history = try? JSONDecoder().decode([ScoreEntry].self, from: data) else {
            return []
        }
        return history
    }
    
    static func saveScore(_ score: Int, for gameKey: String) {
        var history = getHistory(for: gameKey)
        let entry = ScoreEntry(score: score, date: Date())
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

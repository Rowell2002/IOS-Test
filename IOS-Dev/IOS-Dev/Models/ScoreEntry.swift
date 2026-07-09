import Foundation

struct ScoreEntry: Codable, Identifiable {
    let id: UUID
    let score: Int
    let date: Date
    let playerName: String?
    
    init(id: UUID = UUID(), score: Int, date: Date = Date(), playerName: String = "Guest") {
        self.id = id
        self.score = score
        self.date = date
        self.playerName = playerName
    }
}

import Foundation

struct GameSession: Identifiable, Codable, Hashable {
    let id: UUID
    let gameMode: String
    let score: Int
    let date: Date
    let latitude: Double?
    let longitude: Double?
    
    init(id: UUID = UUID(), gameMode: String, score: Int, date: Date = Date(), latitude: Double?, longitude: Double?) {
        self.id = id
        self.gameMode = gameMode
        self.score = score
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
    }
}

import Foundation

struct DailyChallengeHelper {
    static var todayChallengeMode: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        let modes = ["Tap Frenzy", "Light It Up", "Quiz Rush"]
        return modes[day % modes.count]
    }
    
    static var lastPlayedDateKey: String {
        "lastPlayedDailyChallengeDate"
    }
    
    static var hasPlayedToday: Bool {
        guard let lastPlayedDate = UserDefaults.standard.string(forKey: lastPlayedDateKey) else {
            return false
        }
        let todayString = getTodayString()
        return lastPlayedDate == todayString
    }
    
    static func markAsPlayedToday() {
        let todayString = getTodayString()
        UserDefaults.standard.set(todayString, forKey: lastPlayedDateKey)
    }
    
    static func resetDailyChallenge() {
        UserDefaults.standard.removeObject(forKey: lastPlayedDateKey)
    }
    
    private static func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

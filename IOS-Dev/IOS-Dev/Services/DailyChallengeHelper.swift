import Foundation

struct DailyChallengeHelper {
    static var todayChallengeMode: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        let modes = ["Tap Frenzy", "Light It Up", "Quiz Rush"]
        return modes[day % modes.count]
    }
    
    // MARK: - Keys
    static let lastPlayedDateKey = "lastPlayedDailyChallengeDate"
    static let streakCountKey    = "dailyChallengeStreak"
    
    // MARK: - Has Played Today
    static var hasPlayedToday: Bool {
        guard let lastPlayedDate = UserDefaults.standard.string(forKey: lastPlayedDateKey) else {
            return false
        }
        return lastPlayedDate == todayString
    }
    
    // MARK: - Streak
    static var currentStreak: Int {
        UserDefaults.standard.integer(forKey: streakCountKey)
    }
    
    // MARK: - Mark As Played
    static func markAsPlayedToday() {
        let defaults = UserDefaults.standard
        let lastPlayed = defaults.string(forKey: lastPlayedDateKey)
        
        if lastPlayed == todayString {
            // Already recorded today, no double-count
            return
        }
        
        // Check if yesterday was played (to continue streak)
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayString = dateString(for: yesterday)
        
        let currentCount = defaults.integer(forKey: streakCountKey)
        
        if lastPlayed == yesterdayString {
            // Consecutive day – extend streak
            defaults.set(currentCount + 1, forKey: streakCountKey)
        } else {
            // Streak broken or first time – reset to 1
            defaults.set(1, forKey: streakCountKey)
        }
        
        defaults.set(todayString, forKey: lastPlayedDateKey)
    }
    
    // MARK: - Reset
    static func resetDailyChallenge() {
        UserDefaults.standard.removeObject(forKey: lastPlayedDateKey)
        UserDefaults.standard.removeObject(forKey: streakCountKey)
    }
    
    // MARK: - Helpers
    private static var todayString: String { dateString(for: Date()) }
    
    private static func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

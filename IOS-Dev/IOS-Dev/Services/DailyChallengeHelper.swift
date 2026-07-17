import Foundation

struct DailyChallengeHelper {
    static var todayChallengeMode: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        let modes = ["Tap Frenzy", "Light It Up", "Quiz Rush"]
        return modes[day % modes.count]
    }
    
    // MARK: - Keys
    private static var lastPlayedDateKey: String {
        if let currentUser = AuthManager.shared.currentUser {
            return "lastPlayedDailyChallengeDate_\(currentUser.email)"
        }
        return "lastPlayedDailyChallengeDate"
    }
    private static var streakCountKey: String {
        if let currentUser = AuthManager.shared.currentUser {
            return "dailyChallengeStreak_\(currentUser.email)"
        }
        return "dailyChallengeStreak"
    }
    
    // MARK: - Has Played Today
    static var hasPlayedToday: Bool {
        guard let lastPlayedDate = UserDefaults.standard.string(forKey: lastPlayedDateKey) else {
            return false
        }
        return lastPlayedDate == todayString
    }
    
    // MARK: - Streak
    static var currentStreak: Int {
        let defaults = UserDefaults.standard
        guard let lastPlayed = defaults.string(forKey: lastPlayedDateKey) else {
            return 0
        }
        
        if lastPlayed == todayString {
            return defaults.integer(forKey: streakCountKey)
        }
        
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayString = dateString(for: yesterday)
        
        if lastPlayed == yesterdayString {
            return defaults.integer(forKey: streakCountKey)
        }
        
        // Streak broken! Reset to 0
        defaults.set(0, forKey: streakCountKey)
        return 0
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

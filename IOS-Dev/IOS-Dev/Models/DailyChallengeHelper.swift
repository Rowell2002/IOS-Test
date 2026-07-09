import Foundation

struct DailyChallengeHelper {
    static var todayChallengeMode: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        let modes = ["Tap Frenzy", "Light It Up", "Quiz Rush"]
        return modes[day % modes.count]
    }
}

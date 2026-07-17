import Foundation
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "hapticsEnabled") || UserDefaults.standard.object(forKey: "hapticsEnabled") == nil
    }
    
    func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

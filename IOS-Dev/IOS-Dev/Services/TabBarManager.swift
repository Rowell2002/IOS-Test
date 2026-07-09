import Foundation
import Combine

class TabBarManager: ObservableObject {
    static let shared = TabBarManager()
    
    @Published var isHidden: Bool = false
    
    private init() {}
}

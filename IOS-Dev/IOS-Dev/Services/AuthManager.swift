import SwiftUI
import Combine
import CryptoKit

struct UserAccount: Codable, Identifiable, Equatable {
    let id: UUID
    let fullName: String
    let email: String
    let passwordHash: String
}

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var currentUser: UserAccount? = nil
    
    private let accountsKey = "auth_registered_accounts"
    private let sessionKey = "auth_active_session"
    
    init() {
        loadSession()
    }
    
    func loadSession() {
        if let data = UserDefaults.standard.data(forKey: sessionKey),
           let account = try? JSONDecoder().decode(UserAccount.self, from: data) {
            self.currentUser = account
        }
    }
    
    func signUp(fullName: String, email: String, password: String) -> (success: Bool, message: String) {
        var accounts = getAccounts()
        let emailClean = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if accounts.contains(where: { $0.email == emailClean }) {
            return (false, "Email address is already registered.")
        }
        
        let hash = hashPassword(password)
        let newAccount = UserAccount(id: UUID(), fullName: fullName, email: emailClean, passwordHash: hash)
        accounts.append(newAccount)
        saveAccounts(accounts)
        
        // Log in immediately
        loginSession(newAccount)
        return (true, "Account created successfully.")
    }
    
    func login(email: String, password: String) -> (success: Bool, message: String) {
        let accounts = getAccounts()
        let emailClean = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let hash = hashPassword(password)
        
        if let matched = accounts.first(where: { $0.email == emailClean && $0.passwordHash == hash }) {
            loginSession(matched)
            return (true, "Logged in successfully.")
        }
        
        return (false, "Invalid email address or password.")
    }
    
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: sessionKey)
        UserDefaults.standard.set("Guest", forKey: "savedPlayerName")
    }
    
    private func loginSession(_ account: UserAccount) {
        currentUser = account
        if let data = try? JSONEncoder().encode(account) {
            UserDefaults.standard.set(data, forKey: sessionKey)
        }
        // Sync username for highscore history
        UserDefaults.standard.set(account.fullName, forKey: "savedPlayerName")
    }
    
    private func getAccounts() -> [UserAccount] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey),
              let list = try? JSONDecoder().decode([UserAccount].self, from: data) else {
            return []
        }
        return list
    }
    
    private func saveAccounts(_ accounts: [UserAccount]) {
        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: accountsKey)
        }
    }
    
    private func hashPassword(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

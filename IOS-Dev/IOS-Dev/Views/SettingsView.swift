import SwiftUI
import UserNotifications

struct SettingsView: View {
    @ObservedObject var sessionManager = GameSessionManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("dailyChallengeHour") private var dailyChallengeHour = 19
    @AppStorage("dailyChallengeMinute") private var dailyChallengeMinute = 0
    @AppStorage("soundsEnabled") private var soundsEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("appTheme") private var appTheme = "dark"
    
    @State private var challengeTime = Date()
    @State private var showResetConfirmation = false
    @State private var showPermissionDeniedAlert = false
    
    private var cardBg: Color {
        colorScheme == .light ? Color.white : Color.white.opacity(0.04)
    }
    
    private var cardStroke: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : Color.white.opacity(0.08)
    }
    
    private var primaryTextColor: Color {
        colorScheme == .light ? Color.black : Color.white
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .light ? Color.black.opacity(0.6) : Color.white.opacity(0.5)
    }
    
    var body: some View {
        ZStack {
            // Background
            (colorScheme == .light ? Color(red: 245/255, green: 245/255, blue: 250/255) : Color.black)
                .ignoresSafeArea()
            
            RadialGradient(colors: [.purple.opacity(colorScheme == .light ? 0.08 : 0.15), .clear], center: .topTrailing, startRadius: 10, endRadius: 350)
                .ignoresSafeArea()
            RadialGradient(colors: [.blue.opacity(colorScheme == .light ? 0.06 : 0.12), .clear], center: .bottomLeading, startRadius: 10, endRadius: 450)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("PREFERENCES")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                        .tracking(3)
                    
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(primaryTextColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Form / List Container
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // Notifications Settings Block
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.purple)
                                    .font(.headline)
                                
                                Text("Reminders")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(primaryTextColor)
                                
                                Spacer()
                            }
                            
                            Toggle(isOn: $notificationsEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Challenge")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(primaryTextColor)
                                    Text("Get reminded daily to keep your streak.")
                                        .font(.system(size: 12))
                                        .foregroundColor(secondaryTextColor)
                                }
                            }
                            .tint(.purple)
                            .onChange(of: notificationsEnabled) { newValue in
                                if newValue {
                                    requestAndScheduleNotifications()
                                } else {
                                    cancelNotifications()
                                }
                            }
                            
                            if notificationsEnabled {
                                Divider()
                                    .background(Color.primary.opacity(0.12))
                                
                                DatePicker(selection: $challengeTime, displayedComponents: .hourAndMinute) {
                                    Text("Reminder Time")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(primaryTextColor)
                                }
                                .datePickerStyle(.compact)
                                .onChange(of: challengeTime) { newTime in
                                    let calendar = Calendar.current
                                    let components = calendar.dateComponents([.hour, .minute], from: newTime)
                                    dailyChallengeHour = components.hour ?? 19
                                    dailyChallengeMinute = components.minute ?? 0
                                    scheduleNotification(at: newTime)
                                }
                            }
                        }
                        .padding()
                        .background(cardBg)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(cardStroke, lineWidth: 1)
                        )
                        
                        // Appearance / Theme Settings Block
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "paintpalette.fill")
                                    .foregroundColor(.purple)
                                    .font(.headline)
                                
                                Text("Appearance")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(primaryTextColor)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Theme Preference")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(primaryTextColor)
                                
                                Picker("Theme Preference", selection: $appTheme) {
                                    Text("Dark").tag("dark")
                                    Text("Light").tag("light")
                                    Text("System").tag("system")
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        .padding()
                        .background(cardBg)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(cardStroke, lineWidth: 1)
                        )
                        
                        // Audio & Haptics Settings Block
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.purple)
                                    .font(.headline)
                                
                                Text("Audio & Haptics")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(primaryTextColor)
                                
                                Spacer()
                            }
                            
                            Toggle(isOn: $soundsEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sound Effects")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(primaryTextColor)
                                    Text("Play chimes, tap clicks, and game alerts.")
                                        .font(.system(size: 12))
                                        .foregroundColor(secondaryTextColor)
                                }
                            }
                            .tint(.purple)
                            
                            Divider()
                                .background(Color.primary.opacity(0.12))
                            
                            Toggle(isOn: $hapticsEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Vibration Feedback")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(primaryTextColor)
                                    Text("Trigger tactile feedback during gameplay events.")
                                        .font(.system(size: 12))
                                        .foregroundColor(secondaryTextColor)
                                }
                            }
                            .tint(.purple)
                        }
                        .padding()
                        .background(cardBg)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(cardStroke, lineWidth: 1)
                        )
                        
                        // Storage & Reset Settings Block
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                    .font(.headline)
                                
                                Text("Data Management")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(primaryTextColor)
                                
                                Spacer()
                            }
                            
                            Text("Resetting your stats will delete all completed game sessions, high scores, and past histories. This action is permanent.")
                                .font(.system(size: 13))
                                .foregroundColor(secondaryTextColor)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                showResetConfirmation = true
                            }) {
                                Text("Reset All Stats")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.red.opacity(0.85))
                                    .cornerRadius(14)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding()
                        .background(cardBg)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(cardStroke, lineWidth: 1)
                        )
                        
                        // Account Management Block
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.purple)
                                    .font(.headline)
                                
                                Text("Account")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(primaryTextColor)
                                
                                Spacer()
                            }
                            
                            if let currentUser = AuthManager.shared.currentUser {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(currentUser.fullName)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(primaryTextColor)
                                    Text(currentUser.email)
                                        .font(.system(size: 12))
                                        .foregroundColor(secondaryTextColor)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Button(action: {
                                AuthManager.shared.logout()
                            }) {
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.red.opacity(0.06))
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding()
                        .background(cardBg)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(cardStroke, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120) // Leave space for custom tab bar!
                }
            }
        }
        .preferredColorScheme(appTheme == "dark" ? .dark : (appTheme == "light" ? .light : nil))
        .alert("Permission Denied", isPresented: $showPermissionDeniedAlert) {
            Button("OK", role: .cancel) {
                notificationsEnabled = false
            }
        } message: {
            Text("Please enable notifications for PlayHub in system settings to receive reminders.")
        }
        .confirmationDialog("Reset Stats", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Reset All", role: .destructive) {
                sessionManager.resetAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to reset all game history? This cannot be undone.")
        }
        .onAppear {
            loadSavedTime()
        }
    }
    
    private func loadSavedTime() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = dailyChallengeHour
        components.minute = dailyChallengeMinute
        if let savedDate = calendar.date(from: components) {
            challengeTime = savedDate
        }
    }
    
    private func requestAndScheduleNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    scheduleNotification(at: challengeTime)
                } else {
                    showPermissionDeniedAlert = true
                }
            }
        }
    }
    
    private func scheduleNotification(at date: Date) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_challenge"])
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge is Ready! 🏆"
        content.body = "Keep your streak alive! Open PlayHub to play today's Daily Challenge now!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily_challenge", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_challenge"])
    }
}

#Preview {
    SettingsView()
}

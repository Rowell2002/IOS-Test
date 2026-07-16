import SwiftUI

struct HomeScreen: View {
    @State private var hasPlayedDailyChallenge = false
    @State private var streak: Int = 0
    @StateObject private var authManager = AuthManager.shared
    @State private var showProfileSheet = false
    
    var body: some View {
        ZStack {
            // Background Layer: Sleek Dark theme
            Color.black.ignoresSafeArea()
            
            // Grid Background
            GridBackground()
                .ignoresSafeArea()
            
            // Radial Glows
            RadialGradient(colors: [.purple.opacity(0.18), .clear], center: .topTrailing, startRadius: 10, endRadius: 350)
                .ignoresSafeArea()
            RadialGradient(colors: [.blue.opacity(0.15), .clear], center: .bottomLeading, startRadius: 10, endRadius: 450)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    
                    // Top Navigation Header Row
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 200/255, green: 160/255, blue: 255/255))
                            
                            Text("PlayHub")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(Color(red: 200/255, green: 160/255, blue: 255/255))
                        }
                        
                        Spacer()
                        
                        // User Avatar
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 36, height: 36)
                            
                            Text(authManager.currentUser?.avatar ?? "👾")
                                .font(.system(size: 20))
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.purple.opacity(0.35), lineWidth: 1.5)
                        )
                        .contentShape(Circle())
                        .onTapGesture {
                            showProfileSheet = true
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Header Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Jump In")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Select a mode to start playing.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    
                    // Streak Banner
                    if streak > 0 {
                        StreakBannerView(streak: streak)
                            .padding(.horizontal, 20)
                            .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }
                    
                    // Daily Challenge Section
                    if !hasPlayedDailyChallenge {
                        Group {
                            if DailyChallengeHelper.todayChallengeMode == "Tap Frenzy" {
                                NavigationLink(destination: TapFrenzyGameView()) {
                                    DailyChallengeBannerContent()
                                }
                            } else if DailyChallengeHelper.todayChallengeMode == "Light It Up" {
                                NavigationLink(destination: LightItUpGameView()) {
                                    DailyChallengeBannerContent()
                                }
                            } else {
                                NavigationLink(destination: QuizRushGameView()) {
                                    DailyChallengeBannerContent()
                                }
                            }
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            DailyChallengeHelper.markAsPlayedToday()
                        })
                        .buttonStyle(PlainButtonStyle())
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Game Cards
                    VStack(spacing: 16) {
                        GameMenuCard(
                            title: "Tap Frenzy",
                            subtitle: "Tap fast, beat the clock",
                            iconName: "gamecontroller.fill",
                            watermarkName: "gamecontroller",
                            themeColor: Color(red: 46/255, green: 185/255, blue: 118/255),
                            iconBgColor: Color(red: 26/255, green: 77/255, blue: 46/255),
                            destination: TapFrenzyGameView()
                        )
                        
                        GameMenuCard(
                            title: "Light It Up",
                            subtitle: "React before it fades",
                            iconName: "bolt.fill",
                            watermarkName: "bolt",
                            themeColor: Color(red: 100/255, green: 149/255, blue: 237/255),
                            iconBgColor: Color(red: 35/255, green: 45/255, blue: 65/255),
                            destination: LightItUpGameView()
                        )
                        
                        GameMenuCard(
                            title: "Quiz Rush",
                            subtitle: "Live trivia showdown",
                            iconName: "questionmark",
                            watermarkName: "questionmark",
                            themeColor: Color(red: 235/255, green: 110/255, blue: 105/255),
                            iconBgColor: Color(red: 70/255, green: 30/255, blue: 35/255),
                            destination: QuizRushGameView()
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 100) // safety space for tab bar
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showProfileSheet) {
            ProfileEditView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                hasPlayedDailyChallenge = DailyChallengeHelper.hasPlayedToday
                streak = DailyChallengeHelper.currentStreak
            }
        }
    }
}

struct GameMenuCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let iconName: String
    let watermarkName: String
    let themeColor: Color
    let iconBgColor: Color
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            ZStack(alignment: .trailing) {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 18/255, green: 22/255, blue: 32/255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                
                // Watermark watermark & chevron on the right side
                HStack(spacing: 4) {
                    Image(systemName: watermarkName)
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(themeColor.opacity(0.08))
                        .scaleEffect(x: -1, y: 1) // Flip watermark to match style
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeColor.opacity(0.4))
                }
                .padding(.trailing, 24)
                
                // Primary card contents
                HStack(spacing: 16) {
                    // Icon block
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(iconBgColor)
                            .frame(width: 50, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(themeColor.opacity(0.3), lineWidth: 1)
                            )
                        
                        Image(systemName: iconName)
                            .font(.title3)
                            .foregroundColor(themeColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeColor)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 18)
            }
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GridBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Vertical lines
                let stepX: CGFloat = 36
                for x in stride(from: 0, to: width, by: stepX) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                
                // Horizontal lines
                let stepY: CGFloat = 36
                for y in stride(from: 0, to: height, by: stepY) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.035), lineWidth: 0.8)
        }
    }
}

struct DailyChallengeBannerContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("DAILY CHALLENGE", systemImage: "trophy.fill")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                    .tracking(1.5)
                
                Spacer()
                
                Text("PLAY NOW")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(6)
            }
            
            Text(DailyChallengeHelper.todayChallengeMode)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Complete today's challenge to earn maximum points and keep your streak alive!")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(
            LinearGradient(colors: [Color(red: 45/255, green: 30/255, blue: 70/255), Color(red: 25/255, green: 20/255, blue: 45/255)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    LinearGradient(colors: [.yellow, .purple], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.4),
                    lineWidth: 1.5
                )
        )
        .padding(.horizontal, 20)
        .shadow(color: .purple.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Streak Banner View
struct StreakBannerView: View {
    let streak: Int
    
    private var flameColor: Color {
        switch streak {
        case 1...2:  return .orange
        case 3...6:  return Color(red: 1.0, green: 0.45, blue: 0.0)
        case 7...13: return Color(red: 1.0, green: 0.2, blue: 0.1)
        default:     return Color(red: 0.9, green: 0.0, blue: 0.4)  // 14+ day legendary
        }
    }
    
    private var streakLabel: String {
        switch streak {
        case 1:        return "First Day!"
        case 2...6:    return "\(streak)-Day Streak 🔥"
        case 7...13:   return "\(streak)-Day Streak 🔥🔥"
        case 14...29:  return "\(streak)-Day Streak 🔥🔥🔥"
        default:       return "\(streak)-Day Streak 👑"
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Animated flame icon
            ZStack {
                Circle()
                    .fill(flameColor.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: "flame.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, flameColor], startPoint: .top, endPoint: .bottom)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(streakLabel)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Keep going! Complete today's challenge to extend your streak.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Streak count pill
            Text("\(streak)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(flameColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(flameColor.opacity(0.12))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(flameColor.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 18/255, green: 14/255, blue: 10/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(colors: [flameColor.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.2
                        )
                )
        )
        .shadow(color: flameColor.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Profile Edit View
struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthManager.shared
    
    @State private var fullName = ""
    @State private var selectedAvatar = "👾"
    
    let avatarOptions = ["👾", "🚀", "🎮", "🏆", "👑", "🦄", "🦊", "🐯", "🐼", "🦁", "👻", "🧙‍♂️", "😺", "🤖", "⭐", "🍕"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                GridBackground().ignoresSafeArea()
                
                VStack(spacing: 28) {
                    Text("Edit Profile")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                            .shadow(color: .purple.opacity(0.4), radius: 15)
                        
                        Text(selectedAvatar)
                            .font(.system(size: 55))
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 2)
                    )
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SELECT AVATAR")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(1.5)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                            ForEach(avatarOptions, id: \.self) { avatar in
                                Button(action: {
                                    selectedAvatar = avatar
                                    HapticManager.shared.impact(style: .light)
                                }) {
                                    Text(avatar)
                                        .font(.system(size: 30))
                                        .frame(width: 50, height: 50)
                                        .background(selectedAvatar == avatar ? Color.purple.opacity(0.2) : Color.white.opacity(0.04))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedAvatar == avatar ? Color.purple : Color.white.opacity(0.08), lineWidth: 1.5)
                                        )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("FULL NAME")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(1.5)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.4))
                            
                            TextField("", text: $fullName, prompt: Text("Enter your full name").foregroundColor(.white.opacity(0.25)))
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.035))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(14)
                        
                        Button("Save") {
                            saveProfile()
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 45/255, green: 20/255, blue: 70/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(red: 220/255, green: 180/255, blue: 255/255))
                        .cornerRadius(14)
                        .shadow(color: Color(red: 220/255, green: 180/255, blue: 255/255).opacity(0.3), radius: 8, x: 0, y: 4)
                        .disabled(fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                if let user = authManager.currentUser {
                    fullName = user.fullName
                    selectedAvatar = user.avatar ?? "👾"
                }
            }
        }
    }
    
    private func saveProfile() {
        let nameClean = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !nameClean.isEmpty {
            authManager.updateProfile(fullName: nameClean, avatar: selectedAvatar)
            HapticManager.shared.notification(type: .success)
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
    }
}

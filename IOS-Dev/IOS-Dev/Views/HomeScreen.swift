import SwiftUI

struct HomeScreen: View {
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
                            
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
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

#Preview {
    NavigationStack {
        HomeScreen()
    }
}

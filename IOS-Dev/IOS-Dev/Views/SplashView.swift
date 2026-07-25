import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool
    
    @State private var progress: Double = 0.0
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var pulseGlow: Bool = false
    @State private var rotationAngle: Double = 0.0
    @State private var statusText: String = "Initializing Arcades..."
    
    var body: some View {
        ZStack {
            // Dark obsidian background
            Color.black.ignoresSafeArea()
            
            // Grid texture
            GridBackground()
                .ignoresSafeArea()
            
            // Animated Radial Ambient Glows
            RadialGradient(
                colors: [.purple.opacity(pulseGlow ? 0.35 : 0.15), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 400
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulseGlow)
            
            RadialGradient(
                colors: [.blue.opacity(pulseGlow ? 0.30 : 0.12), .clear],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 450
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulseGlow)
            
            VStack(spacing: 36) {
                Spacer()
                
                // Central Logo Area with Pulsing Glow Ring
                ZStack {
                    // Rotating Outer Glow Ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.purple, .cyan, .blue, .purple],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(rotationAngle))
                        .blur(radius: 4)
                        .opacity(0.8)
                    
                    // Outer Glass Card
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 130, height: 130)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: .purple.opacity(0.5), radius: pulseGlow ? 25 : 12)
                    
                    // Game Controller Icon
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 58))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 220/255, green: 170/255, blue: 255/255),
                                    Color(red: 140/255, green: 195/255, blue: 255/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .cyan.opacity(0.6), radius: 10, x: 0, y: 4)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                
                // Branding Header
                VStack(spacing: 8) {
                    Text("PlayHub")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 235/255, green: 200/255, blue: 255/255),
                                    .white,
                                    Color(red: 160/255, green: 210/255, blue: 255/255)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .purple.opacity(0.4), radius: 12, x: 0, y: 4)
                    
                    Text("YOUR ULTIMATE ARCADE")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 200/255, green: 170/255, blue: 255/255))
                        .tracking(3)
                }
                .opacity(textOpacity)
                .offset(y: textOpacity == 1.0 ? 0 : 10)
                
                Spacer()
                
                // Loading Progress Bar & Status
                VStack(spacing: 12) {
                    // Custom Glowing Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 6)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                                )
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 180/255, green: 100/255, blue: 255/255),
                                            Color(red: 90/255, green: 180/255, blue: 255/255),
                                            .cyan
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(12, geo.size.width * CGFloat(progress)), height: 6)
                                .shadow(color: .cyan.opacity(0.7), radius: 6, x: 0, y: 0)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 60)
                    
                    Text(statusText)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .animation(.easeInOut, value: statusText)
                }
                .opacity(textOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startSplashSequence()
        }
    }
    
    private func startSplashSequence() {
        // 1. Animate Icon In
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        // 2. Animate Text & Glow Ring In
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            textOpacity = 1.0
            pulseGlow = true
        }
        
        // Continuous slow rotation for the ring
        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // 3. Progress fill animation & status updates
        withAnimation(.easeInOut(duration: 0.7).delay(0.1)) {
            progress = 0.35
            statusText = "Initializing Arcades..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.6)) {
                progress = 0.75
                statusText = "Loading Profiles & Challenges..."
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.4)) {
                progress = 1.0
                statusText = "Ready to Play!"
            }
        }
        
        // 4. Complete splash and transition out after 2.0s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            withAnimation(.easeInOut(duration: 0.4)) {
                isFinished = false
            }
        }
    }
}

#Preview {
    SplashView(isFinished: .constant(true))
}

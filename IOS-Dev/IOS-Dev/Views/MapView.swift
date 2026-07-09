import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var sessionManager = GameSessionManager.shared
    @State private var selectedSession: GameSession? = nil
    @State private var position: MapCameraPosition = .automatic
    
    var sessionsWithLocation: [GameSession] {
        sessionManager.sessions.filter { $0.latitude != nil && $0.longitude != nil }
    }
    
    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedSession) {
                ForEach(sessionsWithLocation) { session in
                    Annotation(session.gameMode, coordinate: CLLocationCoordinate2D(latitude: session.latitude!, longitude: session.longitude!)) {
                        VStack(spacing: 0) {
                            Text("\(session.score)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(colorForMode(session.gameMode))
                                .cornerRadius(8)
                                .shadow(radius: 3)
                            
                            Image(systemName: "triangle.fill")
                                .resizable()
                                .frame(width: 8, height: 6)
                                .foregroundColor(colorForMode(session.gameMode))
                                .rotationEffect(.degrees(180))
                                .offset(y: -2)
                        }
                        .scaleEffect(selectedSession?.id == session.id ? 1.2 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: selectedSession)
                    }
                    .tag(session)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            
            // UI Overlay
            VStack {
                // Customized Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("GAME MAP")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                        .tracking(3)
                    
                    Text("Session Pins")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 16)
                
                Spacer()
                
                // Pin Detail Card
                if let session = selectedSession {
                    sessionDetailCard(session: session)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.bottom, 12)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            sessionManager.loadSessions()
            LocationManager.shared.requestPermission()
            LocationManager.shared.startUpdating()
            updateCameraPosition()
        }
    }
    
    private func updateCameraPosition() {
        if let lastSession = sessionsWithLocation.first,
           let lat = lastSession.latitude,
           let lon = lastSession.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            position = .camera(MapCamera(centerCoordinate: coordinate, distance: 5000))
        } else {
            // Default position (San Francisco / Apple HQ)
            position = .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.009020), distance: 80000))
        }
    }
    
    private func colorForMode(_ mode: String) -> Color {
        switch mode {
        case "Tap Frenzy": return .green
        case "Light It Up": return .blue
        case "Quiz Rush": return .red
        default: return .purple
        }
    }
    
    private func iconForMode(_ mode: String) -> String {
        switch mode {
        case "Tap Frenzy": return "hand.tap.fill"
        case "Light It Up": return "squareshape.squareshape.dotted"
        case "Quiz Rush": return "lightbulb.fill"
        default: return "gamecontroller.fill"
        }
    }
    
    private func sessionDetailCard(session: GameSession) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(colorForMode(session.gameMode).opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconForMode(session.gameMode))
                    .foregroundColor(colorForMode(session.gameMode))
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.gameMode)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(session.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(session.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(colorForMode(session.gameMode))
                Text("Score")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Button(action: {
                withAnimation {
                    selectedSession = nil
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.3))
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.bottom, 80) // Leave space for custom tab bar
        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    MapView()
}

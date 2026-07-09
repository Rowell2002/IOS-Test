import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let shape: ParticleShape
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let speed: CGFloat
    var rotation: Double
    let rotationSpeed: Double
}

enum ParticleShape {
    case rectangle, circle
}

struct ConfettiView: View {
    @Binding var isTriggered: Bool
    @State private var particles: [ConfettiParticle] = []
    
    private let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .pink, .orange]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Group {
                        if particle.shape == .rectangle {
                            Rectangle()
                                .fill(particle.color)
                        } else {
                            Circle()
                                .fill(particle.color)
                        }
                    }
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .rotationEffect(Angle(degrees: particle.rotation))
                }
            }
            .onAppear {
                if isTriggered {
                    generateParticles(in: geometry.size)
                }
            }
            .onChange(of: isTriggered) { newValue in
                if newValue {
                    generateParticles(in: geometry.size)
                } else {
                    particles.removeAll()
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    private func generateParticles(in size: CGSize) {
        particles.removeAll()
        for _ in 0..<120 {
            let shape: ParticleShape = Bool.random() ? .rectangle : .circle
            let color = colors.randomElement() ?? .purple
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: -size.height...0)
            let particleSize = CGFloat.random(in: 6...14)
            let speed = CGFloat.random(in: 250...450)
            let rotation = Double.random(in: 0...360)
            let rotationSpeed = Double.random(in: 180...360)
            
            particles.append(ConfettiParticle(
                color: color,
                shape: shape,
                x: x,
                y: y,
                size: particleSize,
                speed: speed,
                rotation: rotation,
                rotationSpeed: rotationSpeed
            ))
        }
        
        // Start animation
        let animationDuration = 3.0
        let frameRate: Double = 1.0 / 60.0
        var elapsed = 0.0
        
        Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { timer in
            elapsed += frameRate
            if elapsed >= animationDuration {
                timer.invalidate()
                isTriggered = false
                particles.removeAll()
                return
            }
            
            for i in 0..<particles.count {
                let particle = particles[i]
                let newY = particle.y + (particle.speed * CGFloat(frameRate))
                let newRotation = particle.rotation + (particle.rotationSpeed * frameRate)
                
                // Sway back and forth slightly
                let newX = particle.x + sin(CGFloat(elapsed) * 5 + CGFloat(i)) * 0.8
                
                particles[i] = ConfettiParticle(
                    color: particle.color,
                    shape: particle.shape,
                    x: newX,
                    y: newY,
                    size: particle.size,
                    speed: particle.speed,
                    rotation: newRotation,
                    rotationSpeed: particle.rotationSpeed
                )
            }
        }
    }
}

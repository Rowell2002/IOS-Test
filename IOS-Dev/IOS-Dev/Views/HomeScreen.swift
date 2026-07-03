import SwiftUI

struct HomeScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .teal.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 40) {
                Text("Game Zone")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                NavigationLink(destination: TapFrenzyGameView()) {
                    Text("Tap Frenzy")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                
                NavigationLink(destination: LightItUpGameView()) {
                    Text("Light It Up")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                
                NavigationLink(destination: QuizRushGameView()) {
                    Text("Quiz Rush")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.purple)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

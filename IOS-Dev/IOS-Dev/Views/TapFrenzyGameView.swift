import SwiftUI

struct TapFrenzyGameView: View {
    @StateObject private var viewModel = TapFrenzyViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            Text("High Score: \(viewModel.highScore)")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .padding(.top, 10)
            
            if viewModel.timeLeft > 0 {
                Text("Pressed: \(viewModel.pressCount)")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding(.top, 20)
                
                Button(action: {
                    viewModel.buttonPressed()
                }) {
                    Text("Press")
                        .font(.largeTitle)
                        .frame(width: 200, height: 200)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                        .shadow(color: .red.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                
                Text("Time left: \(viewModel.timeLeft)")
                    .font(.title)
                    .foregroundStyle(.white)
            } else {
                Text("Your pressed count: \(viewModel.pressCount)")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding(.top, 50)
                
                Button("Replay") {
                    viewModel.replay()
                }
                .font(.title)
                .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: [.black, .red.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .onDisappear {
            viewModel.cancelTimer()
        }
    }
}

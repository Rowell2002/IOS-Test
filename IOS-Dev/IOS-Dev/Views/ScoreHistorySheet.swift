import SwiftUI

struct ScoreHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    let gameTitle: String
    let history: [ScoreEntry]
    let highScore: Int
    let themeColor: Color
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, themeColor.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if history.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "trophy.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.4))
                            Text("No Scores Yet")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("Play a round to see your score history recorded here!")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.vertical, 80)
                    } else {
                        List {
                            ForEach(history.sorted(by: {
                                if $0.score != $1.score {
                                    return $0.score > $1.score
                                }
                                return $0.date > $1.date
                            })) { entry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Score: \(entry.score)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(dateFormatter.string(from: entry.date))
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    if entry.score == highScore && highScore > 0 {
                                        Text("Personal Best 👑")
                                            .font(.caption2.bold())
                                            .foregroundColor(.yellow)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.yellow.opacity(0.2))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.yellow, lineWidth: 1)
                                            )
                                    }
                                }
                                .padding(.vertical, 8)
                                .listRowBackground(Color.white.opacity(0.08))
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("\(gameTitle) History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeColor)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

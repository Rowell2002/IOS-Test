import Foundation

struct QuizQuestion: Identifiable {
    let id = UUID()
    let category: String
    let question: String
    let correctAnswer: String
    let allAnswers: [String]
}

struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [TriviaRawQuestion]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct TriviaRawQuestion: Codable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

enum GameLoadState {
    case idle
    case loading
    case success([QuizQuestion])
    case failure(String)
}

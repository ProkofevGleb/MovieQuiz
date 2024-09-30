import Foundation

// структура для результата игры
struct GameResult {
    let correct: Int
    let total: Int
    let date: String
    
    // метод сравнения количества верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}

import Foundation

/// Класс для ведения статистики по игре и записи результатов в UserDefaults

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswers
        case gamesCount
        case questionsCount
        case dateEndRound
        case totalQuestions
        case totalCorrectAnswers
        case totalAccuracy
    }
    
    private var totalCorrectAnswers: Int {
        get {
            // достаем значение из хранилища по ключу
            return storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            // передаем новое значение в хранилище по ключу
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var questionsCount: Int {
        get {
            return storage.integer(forKey: Keys.questionsCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.questionsCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
            let dateEndRound = storage.string(forKey: Keys.dateEndRound.rawValue)
            
            return GameResult(correct: correctAnswers, total: totalQuestions, date: dateEndRound ?? Date().dateTimeString)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correctAnswers.rawValue)
            storage.set(newValue.total, forKey: Keys.totalQuestions.rawValue)
            storage.set(newValue.date, forKey: Keys.dateEndRound.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            return Double(totalCorrectAnswers) / Double(questionsCount) * 100
        }
        set {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    func store(_ gameResult: GameResult) {
        
        totalCorrectAnswers += gameResult.correct
        gamesCount += 1
        questionsCount += gameResult.total
        
        if gameResult.isBetterThan(bestGame) {
            bestGame = gameResult
        }
    }

}

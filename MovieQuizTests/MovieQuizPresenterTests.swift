// фреймворк для тестирования
import XCTest
// импортируем приложение для тестирования
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {

    func showQuestion(quiz step: QuizStepViewModel) {
        
    }
    
    func showResult(quiz result: QuizResultsViewModel) {
        
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        
    }
    
    func showLoadingIndicator(isEnabled: Bool) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    func lockButton(isEnabled: Bool) {
    
    }
    
}

final class StatisticServiceMock: StatisticServiceProtocol {
    var gamesCount: Int = 1
    
    var bestGame = GameResult(correct: 6, total: 20, date: "01/01/2024")
    
    var totalAccuracy: Double = 0.0
    
    func store(_ gameResult: MovieQuiz.GameResult) {
        
    }
}
    


final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let statisticService = StatisticServiceMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock, statisticService: statisticService)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

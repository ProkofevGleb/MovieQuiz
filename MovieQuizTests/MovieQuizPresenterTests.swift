import XCTest // фреймворк для тестирования
@testable import MovieQuiz // импортируем наше приложение для тестирования

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

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

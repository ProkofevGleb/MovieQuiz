import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func showQuestion(quiz step: QuizStepViewModel)
    
    func showResult(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrect: Bool)
    
    func showLoadingIndicator(isEnabled: Bool)
    
    func showNetworkError(message: String)
    
    func lockButton(isEnabled: Bool)
}

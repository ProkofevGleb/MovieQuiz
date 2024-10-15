import Foundation
import UIKit

final class MovieQuizPresenter {
    
    // общее количество вопросов для квиза
    let questionsAmount: Int = 10
    // индекс текущего вопроса
    private var currentQuestionIndex = 1
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 1
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    
    /// метод конвертации, который принимает вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex)/\(questionsAmount)"
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: questionNumber
        )
        return questionStep
    }
}

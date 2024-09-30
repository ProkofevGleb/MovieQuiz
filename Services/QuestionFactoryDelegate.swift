import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    // метод, который будет вызывать фабрика, чтобы отдать готовый вопрос квиза
    func didReceiveNextQuestion(question: QuizQuestion?)
}

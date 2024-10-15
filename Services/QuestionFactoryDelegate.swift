import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    // метод, который будет вызывать фабрика, чтобы отдать готовый вопрос квиза
    func didReceiveNextQuestion(question: QuizQuestion?)
    // сообщение об успешной загрузке
    func didLoadDataFromServer()
    // сообщение об ошибке загрузки
    func didFailToLoadData(with error: Error)
}

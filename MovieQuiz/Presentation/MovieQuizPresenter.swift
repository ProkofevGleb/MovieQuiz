import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // общее количество вопросов для квиза
    let questionsAmount: Int = 10
    // индекс текущего вопроса
    var currentQuestionIndex = 1
    
    // вопрос который видит пользователь
    var currentQuestion: QuizQuestion?

    // счётчик правильных ответов
    var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
        
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator(isEnabled: true)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        // скрываем индикатор загрузки
        viewController?.showLoadingIndicator(isEnabled: false)
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        // возьмём в качестве сообщения описание ошибки
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // получаем вопрос от фабрики вопросов и отображаем его
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        // тут weak self избыточен (исключение)
        DispatchQueue.main.async {
            self.viewController?.showQuestion(quiz: viewModel)
        }
    }
    
    //
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    func restartGame() {
        currentQuestionIndex = 1
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer { correctAnswers += 1 }
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
    
    /// метод, который содержит логику перехода в один из сценариев
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            // идём в состояние "Результат квиза"
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
        
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            // показываем алерт с результатами
            viewController?.showResult(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            // идём в состояние "Вопрос показан"
            questionFactory?.requestNextQuestion()
        }
    }
    
    // формируем ответ на вопрос от пользователя (кнопка "Нет")
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // формируем ответ на вопрос от пользователя (кнопка "Да")
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    // действие после получения ответа на вопрос Да/Нет
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

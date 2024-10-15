import Foundation
import UIKit

final class MovieQuizPresenter {
    
    // общее количество вопросов для квиза
    let questionsAmount: Int = 10
    // индекс текущего вопроса
    var currentQuestionIndex = 1
    
    // обращение к фабрике вопросов
    var questionFactory: QuestionFactory?
    // вопрос который видит пользователь
    var currentQuestion: QuizQuestion?

    // счётчик правильных ответов
    var correctAnswers = 0
    
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    func restartGame() {
        currentQuestionIndex = 1
        correctAnswers = 0
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

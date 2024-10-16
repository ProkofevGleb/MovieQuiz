import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties
    
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol!
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    // общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    // индекс текущего вопроса
    private var currentQuestionIndex = 1
    // текущий вопрос
    private var currentQuestion: QuizQuestion?
    // счётчик правильных ответов
    private var correctAnswers = 0
        
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator(isEnabled: true)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    /// метод получения данных от сервера
    func didLoadDataFromServer() {
        // скрываем индикатор загрузки
        viewController?.showLoadingIndicator(isEnabled: false)
        questionFactory?.requestNextQuestion()
    }
    
    /// метод получения ошибки при загрузке данных
    func didFailToLoadData(with error: Error) {
        // возьмём в качестве сообщения описание ошибки
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    /// метод получения и отображения вопроса
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
    
    // MARK: - Answer
    
    /// формируем ответ на вопрос от пользователя (кнопка "Нет")
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    /// формируем ответ на вопрос от пользователя (кнопка "Да")
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    /// метод, который меняет цвет рамки и запускает отображение следующего вопроса
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        // красим рамку в зависимости от корректности ответа
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // код, который мы хотим вызвать через 1 секунду
            self.proceedToNextQuestionOrResults()
            // снимаем блокировку кнопок
            self.viewController?.lockButton(isEnabled: true)
        }
    }
    
    /// действие после получения ответа на вопрос Да/Нет
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - NextQuestionOrResults
    
    /// метод подсчета вопросов
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    /// метод проверки на последний вопрос
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    /// метод, который содержит логику перехода в один из сценариев
    private func proceedToNextQuestionOrResults() {
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
    
    // MARK: - Results

    /// метод подсчета правильных ответов
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer { correctAnswers += 1 }
    }
    
    /// Собираем результаты игры
    func makeResultsMessage() -> String {
        let currentDate = Date().dateTimeString
        let gameResult = GameResult(correct: correctAnswers, total: questionsAmount, date: currentDate)
        
        guard let statisticService else { fatalError() }
        statisticService.store(gameResult)
        
        // собираем модель для отображения результатов
        let resultMessage =
            """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date))
            Средняя точность: \(String(format: "%.2f%%", statisticService.totalAccuracy))
            """
        
        return resultMessage
    }
    
    // MARK: - Restart
    
    /// метод для сброса при рестарте игры
    func restartGame() {
        currentQuestionIndex = 1
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
}

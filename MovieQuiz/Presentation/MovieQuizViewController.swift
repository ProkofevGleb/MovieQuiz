import UIKit

final class MovieQuizViewController: 
    UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // связываем элементы интерфейса
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    // обращение к созданию презентера
    private let presenter = MovieQuizPresenter()
    
    // обращение к фабрике вопросов
    private var questionFactory: QuestionFactory?
    // вопрос который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    // счётчик правильных ответов
    private var correctAnswers = 0
    // обращение к созданию статистики по игре
    private var statisticService: StatisticServiceProtocol?
    
    // обращение к созданию алерта
    private var alertPresenter: AlertPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupActivityIndicator()
        
        // создаем экземпляр для фабрики вопросов
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        // показываем индикатор загрузки пока не загрузятся данные
        showLoadingIndicator(isEnabled: true)
        questionFactory?.loadData()
        
        statisticService = StatisticService()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
    }
    
    // MARK: - Network
    /// настройки для индикатора загрузки
    func setupActivityIndicator() {
        // индикатор исчезает, когда он неактивен
        activityIndicator.hidesWhenStopped = true
    }
    
    private func showLoadingIndicator(isEnabled: Bool) {
        isEnabled ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        showLoadingIndicator(isEnabled: false)
        
        // создайте и покажите алерт
        let alert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: {
                [weak self] in
                guard let self = self else { return }
                // сбрасываем переменную с индексом вопроса
                self.presenter.resetQuestionIndex()
                // сбрасываем переменную с количеством правильных ответов
                self.correctAnswers = 0
                // заново показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            }
        )   
        alertPresenter?.showAlert(alertModel: alert)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // получаем вопрос от фабрики вопросов и отображаем его
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        // тут weak self избыточен (исключение)
        DispatchQueue.main.async {
            self.showQuestion(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        // скрываем индикатор загрузки
        showLoadingIndicator(isEnabled: false)
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        // возьмём в качестве сообщения описание ошибки
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - AlertPresenterDelegate
    
    func didReceiveResultAlert(alert: UIAlertController?) {
        guard let alert = alert else {
            return
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// метод вывода на экран вопроса
    private func showQuestion(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
        
    /// метод, который меняет цвет рамки и запускает отображение следующего вопроса
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        // красим рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
        }
    }
        
    /// метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            // идём в состояние "Результат квиза"
            // собираем результат игры
            let currentDate = Date().dateTimeString
            let gameResult = GameResult(correct: correctAnswers, total: presenter.questionsAmount, date: currentDate)
            
            guard let statisticService else { fatalError() }
            statisticService.store(gameResult)
            
            // собираем модель для отображения результатов
            let text = """
                Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date))
                Средняя точность: \(String(format: "%.2f%%", statisticService.totalAccuracy))
                """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            // показываем алерт с результатами
            showResult(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            // идём в состояние "Вопрос показан"
            self.questionFactory?.requestNextQuestion()
        }
        // снимаем блокировку кнопок
        lockButton(isEnabled: true)
    }
    
    /// метод показа алерта с результатами квиза
    private func showResult(quiz result: QuizResultsViewModel) {
        
        let alert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: {
                [weak self] in
                guard let self = self else { return }
                // сбрасываем переменную с индексом вопроса
                self.presenter.resetQuestionIndex()
                // сбрасываем переменную с количеством правильных ответов
                self.correctAnswers = 0
                // заново показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.showAlert(alertModel: alert)
    }
    
    private func lockButton(isEnabled: Bool) {
            noButton.isEnabled = isEnabled
            yesButton.isEnabled = isEnabled
        }
        
    // устанавливаем действие при нажатии на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        // блокируем кнопки
        lockButton(isEnabled: false)
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // устанавливаем действие при нажатии на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        // блокируем кнопки
        lockButton(isEnabled: false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

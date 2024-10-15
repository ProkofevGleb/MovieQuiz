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
    
    // обращение к созданию статистики по игре
    private var statisticService: StatisticServiceProtocol?
    
    // обращение к созданию алерта
    private var alertPresenter: AlertPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupActivityIndicator()
        
        presenter.viewController = self
        
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
                // сбрасываем переменные с индексом вопроса и количеством правильных ответов
                self.presenter.restartGame()
                // заново показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            }
        )   
        alertPresenter?.showAlert(alertModel: alert)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // получаем вопрос от фабрики вопросов и отображаем его
        presenter.didReceiveNextQuestion(question: question)
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
    func showQuestion(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
        
    /// метод, который меняет цвет рамки и запускает отображение следующего вопроса
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        // красим рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // код, который мы хотим вызвать через 1 секунду
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            // снимаем блокировку кнопок
            self.lockButton(isEnabled: true)
        }
    }
    
    /// метод показа алерта с результатами квиза
    func showResult(quiz result: QuizResultsViewModel) {
        var message = result.text
        // собираем результат игры
        let currentDate = Date().dateTimeString
        let gameResult = GameResult(correct: presenter.correctAnswers, total: presenter.questionsAmount, date: currentDate)
        
        guard let statisticService else { fatalError() }
        statisticService.store(gameResult)
        
        // собираем модель для отображения результатов
        message = """
            Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date))
            Средняя точность: \(String(format: "%.2f%%", statisticService.totalAccuracy))
            """
        
        let alert = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: {
                [weak self] in
                guard let self = self else { return }
                // сбрасываем переменные с индексом вопроса и количеством правильных ответов
                self.presenter.restartGame()
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
        // вызываем действие
        presenter.noButtonClicked()
    }
    
    // устанавливаем действие при нажатии на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        // блокируем кнопки
        lockButton(isEnabled: false)
        // вызываем действие
        presenter.yesButtonClicked()
    }
}

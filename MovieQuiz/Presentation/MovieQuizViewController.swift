import Foundation
import UIKit

final class MovieQuizViewController:
    UIViewController, MovieQuizViewControllerProtocol, AlertPresenterDelegate {
    
    // MARK: - Outlets
    
    // связываем элементы интерфейса
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    // обращение к MovieQuizPresenter
    private var presenter: MovieQuizPresenter!
    // обращение к AlertPresenter
    private var alertPresenter: AlertPresenter?
    // обращение к созданию статистики по игре
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupActivityIndicator()
        
        statisticService = StatisticService()
        guard let statisticService else {
            print("Ошибка: statisticService не удалось инициализировать.")
            return
        }
        
        presenter = MovieQuizPresenter(viewController: self, statisticService: statisticService)
        
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
    }
    
    // MARK: - Network
    
    /// метод настройки для индикатора загрузки
    func setupActivityIndicator() {
        // индикатор исчезает, когда он неактивен
        activityIndicator.hidesWhenStopped = true
    }
    
    /// метод отображения индикатора загрузки
    func showLoadingIndicator(isEnabled: Bool) {
        isEnabled ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    /// метод получения ошибки и отображения её в алерте
    func showNetworkError(message: String) {
        showLoadingIndicator(isEnabled: false)
        // создание алерта ошибки
        let alert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: {
                [weak self] in
                guard let self = self else { return }
                // сбрасываем переменные с индексом вопроса и количеством правильных ответов
                self.presenter.restartGame()
            }
        )   
        alertPresenter?.showAlert(alertModel: alert)
    }
    
    // MARK: - AlertPresenterDelegate
    
    /// метод показа алерта с результатами
    func didReceiveResultAlert(alert: UIAlertController?) {
        guard let alert = alert else {
            return
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Functions
    
    /// метод вывода на экран вопроса
    func showQuestion(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    /// метод покраски рамки
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    /// метод показа алерта с результатами квиза
    func showResult(quiz result: QuizResultsViewModel) {
        let resultMessage = presenter.makeResultsMessage()
        let alert = AlertModel(
            title: result.title,
            message: resultMessage,
            buttonText: result.buttonText,
            completion: {
                [weak self] in
                guard let self = self else { return }
                // сбрасываем переменные с индексом вопроса и количеством правильных ответов
                self.presenter.restartGame()
            }
        )
        alertPresenter?.showAlert(alertModel: alert)
    }
    
    /// метод блокировки кнопок
    func lockButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    // MARK: - Actions
        
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

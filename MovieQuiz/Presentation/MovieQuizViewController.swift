import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // связываем элементы интерфейса
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    // обращение к фабрике вопросов
    private var questionFactory: QuestionFactoryProtocol?
    // вопрос который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    // индекс текущего вопроса
    private var currentQuestionIndex = 1
    // счётчик правильных ответов
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // получаем вопрос от фабрики вопросов и отображаем его
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        // тут weak self избыточен (исключение)
        DispatchQueue.main.async {
            self.showQuestion(quiz: viewModel)
        }
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex)/\(questionsAmount)"
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: questionNumber
        )
        return questionStep
    }
    
    // метод вывода на экран вопроса
    private func showQuestion(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    // метод вывода на экран результата квиза
    private func showResult(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) {
            [weak self] _ in
            guard let self = self else { return }
            // сбрасываем переменную с индексом вопроса
            self.currentQuestionIndex = 1
            // сбрасываем переменную с количеством правильных ответов
            self.correctAnswers = 0
            // заново показываем первый вопрос
            self.questionFactory?.requestNextQuestion()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
        
        // метод, который меняет цвет рамки и запускает отображение следующего вопроса
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
        
        // метод, который содержит логику перехода в один из сценариев
        private func showNextQuestionOrResults() {
            if currentQuestionIndex == questionsAmount {
                // идём в состояние "Результат квиза"
                let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                showResult(quiz: viewModel)
            } else {
                currentQuestionIndex += 1
                // идём в состояние "Вопрос показан"
                self.questionFactory?.requestNextQuestion()
            }
            // снимаем блокировку кнопок
            lockButton(isEnabled: true)
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

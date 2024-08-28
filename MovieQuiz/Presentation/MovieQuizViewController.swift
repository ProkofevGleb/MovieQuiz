import UIKit

final class MovieQuizViewController: UIViewController {
    
    // связываем элементы интерфейса
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // массив вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
        ]
    
    // индекс текущего вопроса
    private var currentQuestionIndex = 0
    // счётчик правильных ответов
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // берём текущий вопрос из массива вопросов по индексу текущего вопроса
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        showQuestion(quiz: viewModel)
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questions.count)"
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

        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            // сбрасываем переменную с индексом вопроса
            self.currentQuestionIndex = 0
            // сбрасываем переменную с количеством правильных ответов
            self.correctAnswers = 0
            // заново показываем первый вопрос
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.showQuestion(quiz: viewModel)
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
        if currentQuestionIndex == questions.count - 1 {
            // идём в состояние "Результат квиза"
            let text = "Ваш результат: \(correctAnswers)/\(questions.count)"
            let viewModel = QuizResultsViewModel(
                        title: "Этот раунд окончен!",
                        text: text,
                        buttonText: "Сыграть ещё раз")
            showResult(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            showQuestion(quiz: viewModel)
            // снимаем блокировку кнопок
            lockButton(isEnabled: true)
        }
    }
    
    private func lockButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    // устанавливаем действие при нажатии на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        // блокируем кнопки
        lockButton(isEnabled: false)
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // устанавливаем действие при нажатии на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        // блокируем кнопки
        lockButton(isEnabled: false)
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

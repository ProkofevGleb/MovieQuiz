import Foundation

// структура вопроса для квиза
struct QuizQuestion {
  // обложка фильма
  let image: Data
  // строка с вопросом о рейтинге фильма
  let text: String
  // правильный ответ на вопрос
  let correctAnswer: Bool
}

import Foundation

// структура вопроса для квиза
struct QuizQuestion {
  // строка с названием фильма,
  // совпадает с названием картинки афиши фильма в Assets
  let image: String
  // строка с вопросом о рейтинге фильма
  let text: String
  // правильный ответ на вопрос
  let correctAnswer: Bool
}

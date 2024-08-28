import Foundation
import UIKit

// вью модель для состояния "Вопрос показан"
struct QuizStepViewModel {
  // картинка с афишей фильма
  let image: UIImage
  // вопрос о рейтинге фильма
  let question: String
  // строка с порядковым номером этого вопроса
  let questionNumber: String
}

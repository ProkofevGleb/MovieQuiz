import Foundation

// структура алерта для показа результатов
struct AlertModel {
    // строка с заголовком алерта
    let title: String
    // строка с текстом о количестве набранных очков
    let message: String
    // текст для кнопки алерта
    let buttonText: String
    // замыкание для действия по кнопке
    let completion: () -> Void
}

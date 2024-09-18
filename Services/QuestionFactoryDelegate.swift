//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Глеб on 14.09.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    // метод, который будет вызывать фабрика, чтобы отдать готовый вопрос квиза
    func didReceiveNextQuestion(question: QuizQuestion?)
}

import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    // метод, который будет показывать алерт с результатами квиза
    func didReceiveResultAlert(alert: UIAlertController?)
}

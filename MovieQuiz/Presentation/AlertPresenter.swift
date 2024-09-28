import Foundation
import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    // создаем модель алерта для отображения
    func showAlert(alertModel: AlertModel?) {
        
        guard let alertModel = alertModel else {
            return
        }
        
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default) { _ in
                alertModel.completion()
            }
        
        alert.addAction(action)
        delegate?.didReceiveResultAlert(alert: alert)
    }
    
}

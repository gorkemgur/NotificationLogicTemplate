//
//  ErrorHandler.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import UIKit

class ErrorHandler {
    static let shared = ErrorHandler()
    
    private init() {}
    
    func showError(_ error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
    
    func showCustomError(title: String, message: String) {
        showAlert(title: title, message: message)
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            if let topViewController = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
                topViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

//
//  UIViewControllerExtension.swift
//  firebase
//
//  Created by Görkem Gür on 21.09.2024.
//

import UIKit

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? navigationController
        }
        
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController() ?? tabBarController
        }
        
        return self
    }
}

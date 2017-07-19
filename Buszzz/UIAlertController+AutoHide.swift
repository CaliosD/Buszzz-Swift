//
//  UIAlertController+AutoHide.swift
//  Buszzz
//
//  Created by Calios on 24/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func showAuthorizationAlert(message: String) {
        let alertController = UIAlertController.init(title: "提醒", message: message, preferredStyle: .alert)
        alertController.setupAutoHide()
        let settingAction = UIAlertAction.init(title: "前往设置", style: .default, handler: { (_) -> Void in
            guard let settingURL = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingURL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingURL, options: [:], completionHandler: { (success) in
                        DLog("Setting opened: \(success)")
                    })
                } else {
                    UIApplication.shared.openURL(settingURL)
                }
            }
        })
        
        alertController.addAction(settingAction)
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Calios: should be wrapped in DispatchQueue.main.asyn for iOS 8 not showing alert at all.(0323)
        DispatchQueue.main.async(execute: {
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        })
    }
    
    private func setupAutoHide() {
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: .UIApplicationWillResignActive, object: nil)
    }
    @objc private func hide() {
        self.dismiss(animated: true, completion: nil)
    }    
}

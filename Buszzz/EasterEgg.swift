//
//  EasterEgg.swift
//  Buszzz
//
//  Created by Calios on 27/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

extension UIViewController {
    func addEasterEgg() {
        UIApplication.shared.applicationSupportsShakeToEdit = true
    }
    
    open override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let message = "v" + String(shortVersion) + "(build" + String(buildVersion) + ")"
        
        let alertController = UIAlertController.init(title: "Easter Egg", message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "确定", style: .default, handler: nil)
        alertController.addAction(action)
        DispatchQueue.main.async(execute: {
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        })
    }
}

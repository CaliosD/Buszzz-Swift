//
//  AddLocationViewController.swift
//  Buszzz
//
//  Created by Calios on 16/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit
import MapKit

let SearchLocationNotification: NSString = "SearchLocationNotification"

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var longitudeTF: UITextField!
    @IBOutlet weak var latitudeTF: UITextField!
    
    @IBOutlet weak var addressLine: UIView!
    @IBOutlet weak var longitudeLine: UIView!
    @IBOutlet weak var latitudeLine: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addReminderFromSearch), name:SearchLocationNotification as Notification.Name , object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: SearchLocationNotification as Notification.Name, object: nil)
    }
    
    func addReminderFromSearch(notif: Notification) {
        let userInfo = notif.userInfo as! [String: MKMapItem]
        if let location = userInfo["search"] {
            addressTF.text = location.name
            longitudeTF.text = String(location.placemark.coordinate.longitude)
            latitudeTF.text = String(location.placemark.coordinate.latitude)
        }
    }

    @IBAction func saveItemPressed(_ sender: UIBarButtonItem) {
        /*
        if addressTF.checkTextFieldEmpty() && longitudeTF.checkTextFieldEmpty() && latitudeTF.checkTextFieldEmpty() {
            if longitudeTF.checkTextFieldInputDouble() && latitudeTF.checkTextFieldInputDouble() {
                
                let alertController = UIAlertController.init(title: "提醒", message: "请输入备注", preferredStyle: .alert)
                alertController.addTextField(configurationHandler: { (memo) in
                    memo.text = self.addressTF.text!
                })
                let confirm = UIAlertAction.init(title: "保存", style: .default, handler: { (action) in
                    if let memo = alertController.textFields!.first?.text {
                        DataManager.sharedInstance.insertLocation(address: self.addressTF.text!, longitude: Double(self.longitudeTF.text!)!, latitude: Double(self.latitudeTF.text!)!, memo: memo)
                        showAutoHideHUD(text: "保存成功！", completion: {
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    }
                })
                alertController.addAction(confirm)
                let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(cancel)
                present(alertController, animated: true, completion: nil)
            }
        }*/
    }
}

extension AddLocationViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.isEqual(addressTF) {
            addressLine.backgroundColor = BzThemeColor
            longitudeLine.backgroundColor = BzLightGrayColor
            latitudeLine.backgroundColor = BzLightGrayColor
        }
        else if textField.isEqual(longitudeTF) {
            addressLine.backgroundColor = BzLightGrayColor
            longitudeLine.backgroundColor = BzThemeColor
            latitudeLine.backgroundColor = BzLightGrayColor
        }
        else {
            addressLine.backgroundColor = BzLightGrayColor
            longitudeLine.backgroundColor = BzLightGrayColor
            latitudeLine.backgroundColor = BzThemeColor
        }
        return true
    }
}

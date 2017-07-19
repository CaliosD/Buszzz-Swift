//
//  SettingViewController.swift
//  Buszzz
//
//  Created by Calios on 16/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit
import MapKit
import TGPControls
import SVProgressHUD

class SettingViewController: UIViewController {
    
    var location: Location? 
    var mapItem: MKMapItem?
    private var isNew: Bool = false
    
    @IBOutlet weak var memoTF: UITextField!
    @IBOutlet weak var memoLine: UIView!
    @IBOutlet weak var intervalSlider: TGPDiscreteSlider!
    @IBOutlet weak var intervalLabels: TGPCamelLabels!
    @IBOutlet weak var distanceSlider: TGPDiscreteSlider!
    @IBOutlet weak var distanceLabels: TGPCamelLabels!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        intervalLabels.names = intervalNames.map({ String($0) + "s"})
        distanceLabels.names = distanceNames.map({ String($0) + "m"})
        
        intervalSlider.ticksListener = intervalLabels
        distanceSlider.ticksListener = distanceLabels
        
        if location != nil {
            memoTF.text = location!.memo
            intervalSlider.value = CGFloat(location!.intervalIndex)
            intervalLabels.value = UInt(location!.intervalIndex)
            distanceSlider.value = CGFloat(location!.distanceIndex)
            distanceLabels.value = UInt(location!.distanceIndex)
            
            isNew = false
        }
        
        if mapItem != nil {
            memoTF.text = mapItem!.name
            isNew = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        memoTF.resignFirstResponder()
    }
    
    @IBAction func saveItemPressed(_ sender: UIButton) {
        if isTextFieldValid(textfield: memoTF) {
            if isNew {
                if let itm = mapItem {
                    DataManager.sharedInstance.insertLocation(address: itm.name!, longitude: itm.placemark.coordinate.longitude, latitude: itm.placemark.coordinate.latitude, memo: memoTF.text!, intervalIndex: Int(intervalSlider.value), distanceIndex: Int(distanceSlider.value))
                }
            }
            else {
                DataManager.sharedInstance.updateLocation(locationId: (location?.locationId)!, memo: memoTF.text!, intervalIndex: Int(intervalSlider.value), distanceIndex: Int(distanceSlider.value))
            }
            showAutoHideHUD(text: "保存成功!", completion: {
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func deleteItemPressed(_ sender: UIBarButtonItem) {
        if !isNew {
            DataManager.sharedInstance.deleteLocation(locationId: (location?.locationId)!)
        }
        showAutoHideHUD(text: "删除成功!", completion: {
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func backItemPressed(_ sender: UIBarButtonItem) {
        if isNew {
            navigationController?.popViewController(animated: true)
        }
        else {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension SettingViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.isEqual(memoTF) {
            memoLine.backgroundColor     = BzThemeColor
        }
        return true
    }
}

extension SettingViewController {
    func isTextFieldValid(textfield: UITextField) -> Bool {
        return showAlert(condition: (!(textfield.text != nil) || textfield.text == ""), message: textfield.placeholder!)
    }
    
    func showAlert(condition: Bool, message: String) -> Bool{
        if condition {
            let alertController = UIAlertController.init(title: "提醒", message: "\(message)", preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "确定", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            return false
        }
        return true
    }
    public func showAutoHideHUD(text: String, completion: @escaping SVProgressHUDDismissCompletion) {
        SVProgressHUD.showSuccess(withStatus: text)
        SVProgressHUD.dismiss(withDelay: 0.81, completion: completion)
    }
}

//
//  SearchLocationViewController.swift
//  Buszzz
//
//  Created by Calios on 16/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit
import MapKit

class SearchLocationViewController: UIViewController {
    
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var addressLine: UIView!
    @IBOutlet weak var resultTableView: UITableView!
    
    var searchResult: [MKMapItem]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(searchKeyChanged), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftImgView = UIImageView(image: #imageLiteral(resourceName: "ic_searchbar"))
        leftImgView.frame = CGRect(x: 7, y: 6, width: 17, height: 17)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftView.addSubview(leftImgView)
        addressTF.leftViewMode = .always
        addressTF.leftView = leftView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addressTF.text = ""
        resultTableView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        addressTF.becomeFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchPushToSettingSegue" {
            let destinationVC = segue.destination as! SettingViewController
            destinationVC.mapItem =  sender as? MKMapItem
        }
    }
    
    @IBAction func dismissSearch(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func searchKeyChanged() {
        if (addressTF.text != "") {
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = addressTF.text
            let search = MKLocalSearch.init(request: searchRequest)
            search.start { (response : MKLocalSearchResponse?, error: Error?) in
                if let resp = response {
                    self.searchResult = resp.mapItems

                    self.resultTableView.isHidden = false
                    self.resultTableView.reloadData()
                }
            }
        }
    }
}

extension SearchLocationViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        isOnFocus(textField, isOn: true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        isOnFocus(textField, isOn: false)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        resultTableView.isHidden = true
        return true
    }
    
    func isOnFocus(_ textField: UITextField, isOn: Bool) {
        if textField.isEqual(addressTF) {
            addressLine.backgroundColor = isOn ? BzThemeColor : BzLightGrayColor
        }
    }
}

extension SearchLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addressTF.endEditing(true)
        let item = searchResult![indexPath.row] as MKMapItem
        performSegue(withIdentifier: "SearchPushToSettingSegue", sender: item)
    }
}

extension SearchLocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((searchResult) != nil) ? (searchResult!.count) : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCellIdentifier")!
        if ((searchResult) != nil) {
            let itm = searchResult![indexPath.row]
            let placeMark = itm.placemark
            let address = placeMark.addressDictionary!
            
            var subtitleString: String = ""            
            let detail: [String] = ["Name","Thoroughfare", "Street", "State", "City"]
            for str in detail {
                if address[str] != nil {
                    subtitleString = subtitleString.appending(address[str] as! String)
                }
            }
            
            cell.textLabel?.text = placeMark.name
            cell.detailTextLabel?.text = subtitleString
            cell.textLabel?.textColor = BzDarkGrayColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        }
        else {
            cell.textLabel?.text = "无搜索结果"
        }
        return cell
    }
}

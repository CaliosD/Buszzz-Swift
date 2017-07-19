
//
//  LocationListTableViewController.swift
//  Buszzz
//
//  Created by Calios on 15/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift
import UserNotifications
import DZNEmptyDataSet

class LocationListTableViewController: UIViewController{
    
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var locations: Results<Location>? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocationLabel), name: LocationManagerNotification.locationUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scopeNotification), name: LocationManagerNotification.detectingScope, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: LocationManagerNotification.locationUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name: LocationManagerNotification.detectingScope, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        addEasterEgg()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        refreshTableView()
    }
    
    // MARK:- Notification handlers
    func updateLocationLabel(notif: Notification) {
        let userInfo = notif.userInfo as! [String: Any]
        if let isLocating = userInfo[LocationManagerUserInfoKey.isLocating] as? Bool {
            if isLocating {
                if let location: CLLocation = userInfo[LocationManagerUserInfoKey.recentLocation] as? CLLocation {
                    if userLocationLabel != nil {
                        userLocationLabel.text = "    经度：\(location.coordinate.longitude)   纬度：\(location.coordinate.latitude)"
                    }
                }
            }
            else {
                if userLocationLabel != nil {
                    userLocationLabel.text = "    没有定位"
                }
            }
        }
    }

    func scopeNotification(notif: Notification) {
        let userInfo = notif.userInfo as! [String : Any]
        let detectingLocation = userInfo[LocationManagerUserInfoKey.detectingLocation]! as! Location
        NotificationManager.sharedInstance.createReminderNotification(for: detectingLocation)
    }

    // MARK: Actions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushToSettingSegue" {
            let nav = segue.destination as! UINavigationController
            let destinationVC = nav.viewControllers.first as! SettingViewController
            destinationVC.location = sender as? Location
        }
    }
    
    // MARK: Private
    func refreshTableView() {
        locations = DataManager.sharedInstance.retrieveAllLocations()
        userLocationLabel?.isHidden = ((locations?.count) == 0)

        tableView?.reloadEmptyDataSet()
        tableView?.reloadData()
    }
}

// MARK:- TableViewDataSource
extension LocationListTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (locations?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationListCellIdentifier") as! LocationListCell
        let location = (locations?[indexPath.row])! as Location
        cell.configureCell(location: location)

        cell.onSwitchClick = { isOn in
            // TODO: why insert "[unknown self] in" ?
//            [unknown self] in
            isOn ? self.startDetecting(location: location) : self.shutdownAllDetecting()
        }
        
        cell.onSettingPressed = {
            self.performSegue(withIdentifier: "PushToSettingSegue", sender: location)
        }
        return cell
    }
    
    func cell(for location: Location) -> LocationListCell? {
        let index = locations?.index(of: location)
        let path = IndexPath(row: index!, section: 0)
        return tableView.cellForRow(at: path) as? LocationListCell
    }
}

extension LocationListTableViewController: DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "empty_list")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attr = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14 ),
                    NSForegroundColorAttributeName: BzLightGrayColor]
        return NSAttributedString(string: "暂无监测地点，\n点击右上角➕添加一个？", attributes: attr)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -30
    }
}

// MARK:- Detecting Handlers
extension LocationListTableViewController{
    public func startDetecting(location: Location) {
        // TODO: some optimize is needed
        shutdownAllDetecting()
        
        DataManager.sharedInstance.updateDetectingStatus(locationId: location.locationId, status: true)
        refreshTableView()
        
        LocationManager.sharedInstance.startLocating(for: location)
    }
    
    public func shutdownAllDetecting() {
        DataManager.sharedInstance.shutdownAllLocation()
        refreshTableView()
        
        LocationManager.sharedInstance.stopLocating()
        NotificationManager.sharedInstance.removeReminderNotification()
    }
}

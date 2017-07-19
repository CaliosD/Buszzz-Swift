//
//  LocationManager.swift
//  Buszzz
//
//  Created by Calios on 15/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct LocationManagerNotification {
    static let locationUpdate = Notification.Name(rawValue: "locationUpdate")
    static let detectingScope = Notification.Name(rawValue: "detectingScope")
}

struct LocationManagerUserInfoKey {
    static let isLocating = "isLocating"
    static let recentLocation = "recentLocation"
    static let detectingLocation = "detectingLocation"
}

var DetectingInterval: Int?

final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = LocationManager(isLocating: false)
    private var isLocating: Bool //= false
    private var locationManager: CLLocationManager
    private var detectingLocation: Location?
    private var detectingCLLocation: CLLocation?
    
    private var timer: Timer?
    
    init(isLocating status: Bool) {
        self.isLocating = status
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
    
        super.init()
        
        locationManager.delegate = self
    }

    public func setupLocationSettings() {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
                UIAlertController.showAuthorizationAlert(message: "你没有开启GPS定位，请开启后操作！")                
            }
            else {
                locationManager.requestAlwaysAuthorization()
                
                if #available(iOS 9.0, *) {
                    locationManager.allowsBackgroundLocationUpdates = true
                }
            }
        }
        else {
            DLog("CLLocationManager locationServices not enabled!")
        }
    }
    
    public func startLocating(for location: Location) {

        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            detectingLocation = location
            detectingCLLocation = CLLocation.init(latitude: location.latitude, longitude: location.longitude)
            DetectingInterval = intervalNames[location.intervalIndex]
            
            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                pump()
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(intervalNames[location.intervalIndex] - 1), target: self, selector: #selector(pump), userInfo: nil, repeats: true)
            }
        }
    }
    
    public func stopLocating() {
        locationManager.stopUpdatingLocation()
        isLocating = false
        timer?.invalidate()
        NotificationCenter.default.post(name: LocationManagerNotification.locationUpdate, object: nil, userInfo: [LocationManagerUserInfoKey.isLocating: false])
    }
    
    @objc private func pump() {
        if isLocating == false {
            DispatchQueue.main.async {
                self.locationManager.startUpdatingLocation()
            }
            isLocating = true
            
            let dispatchTime = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: { 
                self.locationManager.stopUpdatingLocation()
                self.isLocating = false
            })
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mostRecentLocation = locations.last
        DLog("Current location: \(String(describing: mostRecentLocation?.coordinate.latitude)), \(String(describing: mostRecentLocation?.coordinate.longitude))")
        if detectingLocation != nil {
            NotificationCenter.default.post(name: LocationManagerNotification.locationUpdate, object: nil, userInfo: [LocationManagerUserInfoKey.recentLocation: mostRecentLocation!, LocationManagerUserInfoKey.isLocating: true])
            
            let distance = detectingCLLocation!.distance(from: mostRecentLocation!)
            DLog("distance: \(distance), detecting distance: \(distanceNames[detectingLocation!.distanceIndex])")
            if distance < Double((distanceNames[detectingLocation!.distanceIndex])) {
                NotificationCenter.default.post(name: LocationManagerNotification.detectingScope, object: nil, userInfo: [LocationManagerUserInfoKey.detectingLocation: detectingLocation!])
            }
        }
    }

}


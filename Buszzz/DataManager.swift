//
//  DataManager.swift
//  Buszzz
//
//  Created by Calios on 16/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import RealmSwift

let intervalNames = [5, 10, 15, 20, 25]
let distanceNames = [100, 500, 1000, 2000, 3000]

class Location: Object {
    
    dynamic var locationId : Int = 0
    dynamic var memo : String = ""
    dynamic var address : String = ""
    dynamic var distanceIndex : Int = 2
    dynamic var intervalIndex : Int = 2
    dynamic var longitude : Double = 0.0
    dynamic var latitude : Double = 0.0
    dynamic var isDetecting: Bool = false
    
    override static func primaryKey() -> String? {
        return "locationId"
    }
}

final class DataManager: NSObject {
    static let sharedInstance = DataManager(name:"realmdb")
    
    init(name: String) {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(name).realm")
        DLog("db path: \(String(describing: config.fileURL))")
        Realm.Configuration.defaultConfiguration = config
    }
    
    func increaseID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Location.self).max(ofProperty: "locationId") as Int? ?? 0) + 1
    }
    
    func insertLocation(address:String, longitude: Double, latitude: Double, memo: String, intervalIndex: Int, distanceIndex: Int) {
        let location = Location()
        location.locationId = increaseID()
        location.address = address
        location.longitude = longitude
        location.latitude = latitude
        location.memo = memo
        location.intervalIndex = intervalIndex
        location.distanceIndex = distanceIndex
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(location)
        }
    }
    
    func retrieveAllLocations() -> Results<Location> {
        let realm = try! Realm()
        return realm.objects(Location.self)
    }
    
    // Not used.
    func retrieveLocationById(locationId: Int) -> Location {
        let realm = try! Realm()
        return realm.object(ofType: Location.self, forPrimaryKey: locationId)!
    }
    
    func updateLocation(locationId: Int, memo: String, intervalIndex: Int, distanceIndex: Int) {
        let realm = try! Realm()
        try! realm.write({ 
            realm.create(Location.self, value: ["locationId": locationId, "memo": memo, "intervalIndex": intervalIndex, "distanceIndex":distanceIndex], update: true)
        })
    }
    
    func shutdownAllLocation() {
        if let results: Results<Location> = allDetectingLocation() {
            for location in results {
                updateDetectingStatus(locationId: location.locationId, status: false)
            }
        }
    }
    
    func updateDetectingStatus(locationId: Int, status: Bool) {
        let realm = try! Realm()
        try! realm.write({
            realm.create(Location.self, value: ["locationId": locationId, "isDetecting": status], update: true)
        })
    }
    
    func allDetectingLocation() -> Results<Location>? {
        let realm = try! Realm()
        return realm.objects(Location.self).filter("isDetecting = true")
    }
    
    // Not used.
    func detectingStatusById(locationId: Int) -> Bool {
        let realm = try! Realm()
        return realm.object(ofType: Location.self, forPrimaryKey: locationId)!.isDetecting
    }
    
    func deleteLocation(locationId: Int) {
        let realm = try! Realm()
        let location = realm.object(ofType: Location.self, forPrimaryKey: locationId)
        
        try! realm.write {
            realm.delete(location!)
        }
    }
}

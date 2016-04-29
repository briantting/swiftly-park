//
//  ViewController.swift
//  park
//
//  Created by Ethan Brooks on 4/11/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    // Tracks if user is currently driving
    var isDriving: Bool = true
    // Tracks if user has stopped
    var stopSet: Bool = false
    // Tracks latitude of stop
    var stopLatitude: Double = 0
    // Tracks longitude of stop
    var stopLongitude: Double = 0
    // Tracks time of stop
    var stopTime: Double = 0
    // Tracks previous location
    var prevLocation: CLLocation? = nil
    // Tracks previous time
    var prevTime: Double = 0
    
    var spot: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let regionDiameter: CLLocationDistance = 1000
        func centerMapOnLocation(location: CLLocationCoordinate2D) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionDiameter, regionDiameter)
            mapView.setRegion(coordinateRegion, animated: true)
        }
       
        let philadelphia = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
        centerMapOnLocation(philadelphia)
        let spot = philadelphia
        mapView.addAnnotations([
            ParkingSpot(CLLocationCoordinate2D(latitude: 39.9527, longitude: -75.1651)),
            ParkingSpot(spot)])
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        
        let latitude: Double = latestLocation.coordinate.latitude
        let longitude: Double = latestLocation.coordinate.longitude
        let time: Double = latestLocation.timestamp.timeIntervalSinceReferenceDate
        // Calculates speed
        var speed: Double = 0
        if prevLocation != nil {
            speed = latestLocation.distanceFromLocation(prevLocation!) / (time - prevTime)
        }
        prevLocation = latestLocation
        prevTime = time
        
        /*
         If speed is greater than 5m/s we assume that the user is driving. If speed is less than 0.5m/s
         we assume that the user has stopped. If user was driving, has stopped, and remains under 5m/s
         for 300 seconds then the stop is marked as a park and the user is not driving.
         */
        
        // User unparked and is driving
        if !isDriving && speed >= 5 {
            isDriving = true
            // send unpark, current latitude and longitude
        }
            // User stop is not a park
        else if stopSet && speed >= 5 {
            stopSet = false
        }
            // User stop is a park
        else if stopSet && speed < 5 && time - stopTime > 300 {
            isDriving = false
            stopSet = false
            // send park, stop latitude and longitude
        }
            // User has stopped
        else if isDriving && !stopSet && speed < 0.5 {
            stopSet = true
            stopLatitude = latitude
            stopLongitude = longitude
            stopTime = time
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
}



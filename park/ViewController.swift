//
//  ViewController.swift
//  park
//
//  Created by Ethan Brooks on 4/11/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class Pin: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var server: HTTPManager!

    // Tracks if user is currently driving
    var isDriving: Bool = true
    // Tracks previous location
    var prevLocation: CLLocation? = nil
    // Tracks previous speed
    var prevSpeed: Double = 5
    // PARKING SPOTS INSTANCE VARIABLE
    // parkingSpots
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        server = HTTPManager()
        let (upperLeft, lowerRight) = getMapBounds()
        // THIS WILL RETURN PARKING SPOTS SET RETURN TO INSTANCE VARIABLE
         server.getParkingSpots(upperLeft, lowerRight)
        
        // set paramaeters of initial map to be displayed
        mapView.delegate = self // make ViewController responsive to changes in mapView
        let regionDiameter: CLLocationDistance = 1000
        func centerMapOnLocation(location: CLLocationCoordinate2D) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionDiameter, regionDiameter)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        
        let cupertino = CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118)
        centerMapOnLocation(cupertino)
        
        updateMap()
        
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

        // Calculates speed (m/s) from distance traveled each second
        var speed: Double = prevSpeed
        if prevLocation != nil {
            speed = latestLocation.distanceFromLocation(prevLocation!)
        }
        prevLocation = latestLocation
        
        /*
         Simplified Parking
        */
        
        // Park
        if isDriving && speed < 5 {
            isDriving = false
            // THIS SHOULD BE IMPLEMENTED
            // server.postParkingSpot(latestLocation.coordinate, false)
        }
        // Vacate
        else if !isDriving && speed >= 5 {
            isDriving = true
            // THIS SHOULD BE IMPLEMENTED
            // server.postParkingSpot(latestLocation.coordinate, true)
        }
        updateMap()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations.filter() {$0 !== mapView.userLocation})
        
        // FOR DEBUGGING
//        let (upperLeft, lowerRight) = getMapBounds()
//        var spots = ParkingSpots()
//        let spots = [
//            CLLocationCoordinate2D(latitude: 37.33379, longitude: -122.03119),
//            CLLocationCoordinate2D(latitude: 37.33171, longitude: -122.03118),
//            CLLocationCoordinate2D(latitude: 37.33131, longitude: -122.03118),
//            CLLocationCoordinate2D(latitude: 37.33141, longitude: -122.03128),
//        ]
//        let (upperLeft, lowerRight) = getMapBounds()
//        var parkingSpots = ParkingSpots()
//        for spot in spots {
//            parkingSpots.addSpot(spot)
//        }
//        
//        print("\ntest")
//        let ySpots = parkingSpots.spotsByY.valuesBetween(YSpot(upperLeft), and: YSpot(lowerRight))
//        let xSpots = parkingSpots.spotsByX.valuesBetween(XSpot(upperLeft), and: XSpot(lowerRight))
//        print(ySpots)
//        print(xSpots)
//        
//        for spot in parkingSpots.getSpots(upperLeft, lowerRight) {
//            print(spot.lat, spot.long)
//        }
        
//        spots.addSpot(cupertino)
//        mapView.addAnnotations(spots.map({XSpot($0)}))
        
        //mapView.addAnnotation(mapView.userLocation)
    }
    
    func getMapBounds() -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
        let region = self.mapView.region
        let center = region.center
        let span = region.span
        let half_height = span.latitudeDelta/2
        let half_width = span.longitudeDelta/2
        let upperLeft = CLLocationCoordinate2D(latitude: center.latitude + half_height, longitude: center.longitude - half_width)
        let lowerRight = CLLocationCoordinate2D(latitude: center.latitude - half_height, longitude: center.longitude + half_width)
        return (upperLeft, lowerRight)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateMap()
    }
    
}

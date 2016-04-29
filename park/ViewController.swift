//
//  ViewController.swift
//  park
//
//  Created by Ethan Brooks on 4/11/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var server : HTTPManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        server = HTTPManager()
        server.getParkingSpots()
        
        
        let regionDiameter: CLLocationDistance = 1000
        func centerMapOnLocation(location: CLLocationCoordinate2D) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                                      regionDiameter,
                                                                      regionDiameter)
            mapView.setRegion(coordinateRegion, animated: true)

        }
       
        let philadelphia = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
        centerMapOnLocation(philadelphia)
        let spot = ParkingSpot(philadelphia)
        mapView.addAnnotation(spot)
    }
}



//
//  ViewController.swift
//  park
//
//  Created by Ethan Brooks on 4/11/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import UIKit
import MapKit

class parkingSpot: MKPointAnnotation {
    var pinColor: UIColor
    let lat: Double
    let long: Double
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.long = coordinate.latitude
        self.lat = coordinate.longitude
        self.pinColor = UIColor.brownColor()
        super.init()
        self.coordinate = coordinate
    }
}

class longSpot: parkingSpot, Comparable {}
class latSpot: parkingSpot, Comparable {
    func asLongSpot() -> longSpot {
        return longSpot(self.coordinate)
    }
}

func < (left: longSpot, right: longSpot) -> Bool {
    return left.lat < right.lat
}

func < (left: latSpot, right: latSpot) -> Bool {
    return left.long < right.long
}

func getSpots(spotsByLat: Node<longSpot>,
              spotsByLong: Node<latSpot>,
              upperLeft: CLLocationCoordinate2D,
              lowerRight: CLLocationCoordinate2D) -> Set<parkingSpot> {
    
    let upperLeftSpot = parkingSpot(upperLeft)
    let lowerRightSpot = parkingSpot(lowerRight)
    let spotsInXRange = spotsByLat.valuesBetween(upperLeftSpot as! longSpot,
                                             and: lowerRightSpot as! longSpot)
    return spotsByLong.valuesBetween(upperLeftSpot as! latSpot,
                                and: lowerRightSpot as! latSpot,
                                if: {spotsInXRange.contains($0.asLongSpot())})
}

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let regionDiameter: CLLocationDistance = 1000
        func centerMapOnLocation(location: CLLocationCoordinate2D) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                                      regionDiameter,
                                                                      regionDiameter)
            mapView.setRegion(coordinateRegion, animated: true)

        }
       
        let philadelphia = CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
        centerMapOnLocation(philadelphia)
        let spot = parkingSpot(philadelphia)
        mapView.addAnnotation(spot)
    }
}


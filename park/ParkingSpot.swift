//
//  ParkingSpot.swift
//  park
//
//  Created by Ethan Brooks on 4/26/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation
import MapKit

func approxLessThan(left: Double, _ right: Double, _ epsilon: Double) -> Bool {
    return right - left > epsilon
}

func almostEqual(left: Double, _ right: Double, _ epsilon: Double) -> Bool {
    return abs(left - right) < epsilon
}

func <(left: XSpot, right: XSpot) -> Bool {
    return approxLessThan(left.x, right.x, ParkingSpot.epsilon)
}

func <(left: YSpot, right: YSpot) -> Bool {
    return approxLessThan(left.y, right.y, ParkingSpot.epsilon)
}

class ParkingSpot: MKPointAnnotation {
//    var pinColor: UIColor
    var lat: Double
    var long: Double
    var x: Double
    var y: Double
    
    override var hashValue: Int {
        let strings = [self.x, self.y].map({String(Int(round($0)))})
        return Int(strings.reduce("", combine: (+)))!
    }
    
    override var description: String {
        return "lat: \(lat), long: \(long)"
    }
    
    static let epsilon: Double = 10
    
    init(_ coordinate: CLLocationCoordinate2D) {
        lat = coordinate.latitude
        long = coordinate.longitude
        let mapPoint = MKMapPointForCoordinate(coordinate)
        x = mapPoint.x
        y = mapPoint.y
        super.init()
        self.coordinate = coordinate
    }
    
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let spot = object as? ParkingSpot {
            return round(x) == round(spot.x)
                && round(y) == round(spot.y)
        }
        return false
    }

}

class XSpot: ParkingSpot, Comparable { }

class YSpot: ParkingSpot, Comparable {
    func asXSpot() -> XSpot {
        return XSpot(self.coordinate)
    }
}

struct ParkingSpots {
    var spotsByX = Node<XSpot>.Leaf
    var spotsByY = Node<YSpot>.Leaf
    
    mutating func addSpot(coordinate: CLLocationCoordinate2D) {
        spotsByX = spotsByX.insert(XSpot(coordinate))
        spotsByY = spotsByY.insert(YSpot(coordinate))
    }
    
    func getSpots(upperLeft: CLLocationCoordinate2D,
               _ lowerRight: CLLocationCoordinate2D) -> Set<ParkingSpot> {
        
        let spotsInXRange = spotsByX
            .valuesBetween(XSpot(upperLeft), and: XSpot(lowerRight))
            .map({$0 as ParkingSpot})
        print(upperLeft.latitude, upperLeft.longitude)
        print(lowerRight.latitude, lowerRight.longitude)
            
        return spotsByY.valuesBetween(YSpot(upperLeft),
                           and: YSpot(lowerRight),
                           if: {spotsInXRange.contains($0.asXSpot())})
    }
    
    mutating func removeSpot(coordinate: CLLocationCoordinate2D) {
        spotsByX = spotsByX.remove(XSpot(coordinate))
        spotsByY = spotsByY.remove(YSpot(coordinate))
    }
    
    mutating func removeSpotNear(coordinate: CLLocationCoordinate2D,
                                 radius: Double) {
        // convert point
        let mapPoint = MKMapPointForCoordinate(coordinate)
        let location = CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude)
        
        // get bounds
        let upperLeft = MKCoordinateForMapPoint(MKMapPoint(
            x: mapPoint.x - radius, y: mapPoint.y + radius))
        let lowerRight = MKCoordinateForMapPoint(MKMapPoint(
            x: mapPoint.x + radius, y: mapPoint.y - radius))
        
        // get spots within radius
        let nearby = getSpots(upperLeft, lowerRight).filter() { spot in
            let spotLocation = CLLocation(latitude: spot.lat,
                                          longitude: spot.long)
            return location.distanceFromLocation(spotLocation) < radius
        }
        
        // remove random choice from spots within radius
        if let spot = nearby.first {
            removeSpot(spot.coordinate)
            print("Removed Spot")
        } else {
            print("no spot to remove")
        }
    }
}
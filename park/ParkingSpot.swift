//
//  ParkingSpot.swift
//  park
//
//  Created by Ethan Brooks on 4/26/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation
import MapKit

/**
 - params left, right:
 values to be compared
 
 - param epsilon:
 see returns
 
 - returns:
 true if left is less than right by more than epsilon
 */
func lessThanWithEpsilon(left: Double, _ right: Double, _ epsilon: Double) -> Bool {
    return right - left > epsilon
}

/**
 - params left, right:
 values to be compared
 
 - param epsilon:
 see returns
 
 - returns:
 true if difference between values is less than epsilon
 */
func almostEqual(left: Double, _ right: Double, _ epsilon: Double) -> Bool {
    return abs(left - right) < epsilon
}

/**
 necessary for creating a binary tree of XSpots
 
 - params left, right:
 values to be compared
 
 - returns:
 true if left's x coordinate is less than right's x by more than ParkingSpot.epsilon
 */
func <(left: XSpot, right: XSpot) -> Bool {
    return lessThanWithEpsilon(left.x, right.x, ParkingSpot.epsilon)
}

/**
 necessary for creating a binary tree of YSpots
 
 - params left, right:
 values to be compared
 
 - returns:
 true if left's y coordinate is less than right's y by more than ParkingSpot.epsilon
 */
func <(left: YSpot, right: YSpot) -> Bool {
    return lessThanWithEpsilon(left.y, right.y, ParkingSpot.epsilon)
}

/**
  Object representing a parking spot location
 */
class ParkingSpot: MKPointAnnotation {
//    var pinColor: UIColor
    var lat: Double
    var long: Double
    var x: Double
    var y: Double
    
   /**
     necessary for comparing sets of ParkingSpot objects
    */
    override var hashValue: Int {
        let strings = [self.x, self.y].map({String(Int(round($0)))})
        return Int(strings.reduce("", combine: (+)))!
    }
    
   /**
     how swift prints ParkingSpot objects
    */
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
    
    /**
     necessary for comparison of sets of ParkingSpot objects
    */
    override func isEqual(object: AnyObject?) -> Bool {
        if let spot = object as? ParkingSpot {
            return round(x) == round(spot.x)
                && round(y) == round(spot.y)
        }
        return false
    }

}

/**
 These classes are explained under ParkingSpots
*/
class XSpot: ParkingSpot, Comparable { }
class YSpot: ParkingSpot, Comparable {
    func asXSpot() -> XSpot {
        return XSpot(self.coordinate)
    }
}

/**
 ParkingSpots is essentially a pair of trees of ParkingSpot objects,
 one sorted by x, the other sorted by y. This allows us to quickly
 retrieve parking spots corresponging to 
*/
struct ParkingSpots: Model {
    var spotsByX = Node<XSpot>.Leaf
    var spotsByY = Node<YSpot>.Leaf
    
    mutating func addSpot(coordinate: CLLocationCoordinate2D) {
        spotsByX = spotsByX.insert(XSpot(coordinate))
        spotsByY = spotsByY.insert(YSpot(coordinate))
    }
    
    func getSpots(upperLeft: CLLocationCoordinate2D,
               _ lowerRight: CLLocationCoordinate2D) -> Set<ParkingSpot> {
        
        print("TEST TEST")
        let spotsInXRange = spotsByX
            .valuesBetween(XSpot(upperLeft), and: XSpot(lowerRight))
            .map({$0 as ParkingSpot})
        //print(upperLeft.latitude, upperLeft.longitude)
        //print(lowerRight.latitude, lowerRight.longitude)
            
        return spotsByY.valuesBetween(YSpot(upperLeft),
                           and: YSpot(lowerRight),
                           if: {spotsInXRange.contains($0.asXSpot())})
    }
    
    mutating func removeSpot(coordinate: CLLocationCoordinate2D) -> Void {
        print("TEST TEST")
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
            print("Removed Spot:", spot.coordinate)
        } else {
            print("No spot to remove.")
        }
    }
}
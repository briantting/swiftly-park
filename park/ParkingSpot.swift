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
            return almostEqual(x, spot.x, ParkingSpot.epsilon)
                && almostEqual(y, spot.y, ParkingSpot.epsilon)
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
        
        print("TEST TEST")
        let spotsInXRange = spotsByX
            .valuesBetween(XSpot(upperLeft), and: XSpot(lowerRight))
            .map({$0 as ParkingSpot})
        print(upperLeft.latitude, upperLeft.longitude)
        print(lowerRight.latitude, lowerRight.longitude)
            
        return spotsByY.valuesBetween(YSpot(upperLeft),
                           and: YSpot(lowerRight),
                           if: {spotsInXRange.contains($0.asXSpot())})
    }
    
    mutating func removeSpot(coordinate: CLLocationCoordinate2D) -> Void {
        print("TEST TEST")
        spotsByX = spotsByX.remove(XSpot(coordinate))
        spotsByY = spotsByY.remove(YSpot(coordinate))
    }
}
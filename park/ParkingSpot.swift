//
//  ParkingSpot.swift
//  park
//
//  Created by Ethan Brooks on 4/26/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation
import MapKit

class ParkingSpot: MKPointAnnotation {
//    var pinColor: UIColor
    var lat: Double
    var long: Double
    var x: Double
    var y: Double
    
    static let epsilon: Double = 5
    
    init(_ coordinate: CLLocationCoordinate2D) {
        lat = coordinate.latitude
        long = coordinate.longitude
        let mapPoint = MKMapPointForCoordinate(coordinate)
        x = mapPoint.x
        y = mapPoint.y
//        self.init(coordinate)
        super.init()
        self.coordinate = coordinate
    }
    
    init(m mapPoint: MKMapPoint) {
        x = mapPoint.x
        y = mapPoint.y
        let coordinate = MKCoordinateForMapPoint(mapPoint)
        lat = coordinate.latitude
        long = coordinate.longitude
//        self.init(coordinate)
        super.init()
        self.coordinate = coordinate
    }
}

func approxLessThan(left: Double, _ right: Double, _ epsilon: Double) -> Bool {
    return right - left > epsilon
}

func approxEqual(left: Double, _ right: Double, _ epsilon: Double) -> Bool {
    return abs(left - right) < epsilon
}

func <(left: XSpot, right: XSpot) -> Bool {
    return approxLessThan(left.x, right.x, ParkingSpot.epsilon)
}

func <(left: YSpot, right: YSpot) -> Bool {
    return approxLessThan(left.y, right.y, ParkingSpot.epsilon)
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
    
    mutating func addSpot(mapPoint: MKMapPoint) {
        spotsByX = spotsByX.insert(XSpot(m: mapPoint))
        spotsByY = spotsByY.insert(YSpot(m: mapPoint))
    }
    
    func getSpots(upperLeft: CLLocationCoordinate2D,
                  _ lowerRight: CLLocationCoordinate2D) -> Set<ParkingSpot> {
        
        let spotsInXRange = spotsByX.valuesBetween(XSpot(upperLeft),
                           and: XSpot(lowerRight))
        print(upperLeft.latitude, upperLeft.longitude)
        print(lowerRight.latitude, lowerRight.longitude)
            
        return spotsByY.valuesBetween(YSpot(upperLeft),
                           and: YSpot(lowerRight),
                           if: {spotsInXRange.contains($0.asXSpot())})
    }
}
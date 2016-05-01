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
    let lat: Double
    let long: Double
    let x: Double
    let y: Double
    
    static let epsilon: Double = 5
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.long = coordinate.latitude
        self.lat = coordinate.longitude
        let mapPoint = MKMapPointForCoordinate(coordinate)
        self.x = mapPoint.x
        self.y = mapPoint.y
        super.init()
    }
    
    init(mapPoint: MKMapPoint) {
        self.x = mapPoint.x
        self.y = mapPoint.y
        let coordinate = MKCoordinateForMapPoint(mapPoint)
        self.lat = coordinate.latitude
        self.long = coordinate.longitude
        super.init()
//        self.coordinate = coordinate // TODO: Not sure if commenting this breaks stuff
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

func ==(left: XSpot, right: XSpot) -> Bool {
    return approxEqual(left.x, right.x, ParkingSpot.epsilon)
}

func <(left: YSpot, right: YSpot) -> Bool {
    return approxLessThan(left.y, right.y, ParkingSpot.epsilon)
}

func ==(left: YSpot, right: YSpot) -> Bool {
    return approxEqual(left.y, right.y, ParkingSpot.epsilon)
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
        spotsByX = spotsByX.insert(XSpot(mapPoint: mapPoint))
        spotsByY = spotsByY.insert(YSpot(mapPoint: mapPoint))
    }
    
    func getSpots(upperLeft: CLLocationCoordinate2D,
                  _ lowerRight: CLLocationCoordinate2D) -> Set<ParkingSpot> {
        
        let spotsInXRange = spotsByX.valuesBetween(XSpot(upperLeft),
                           and: XSpot(lowerRight))
        return spotsByY.valuesBetween(YSpot(upperLeft),
                           and: YSpot(lowerRight),
                           if: {spotsInXRange.contains($0.asXSpot())})
    }
}
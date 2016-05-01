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
    var pinColor: UIColor
    let lat: Double
    let long: Double
    
    static let epsilon: Double = 5
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.long = coordinate.latitude
        self.lat = coordinate.longitude
        self.pinColor = UIColor.brownColor()
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

func <(left: longSpot, right: longSpot) -> Bool {
    return approxLessThan(left.long, right.long, ParkingSpot.epsilon)
}

func ==(left: longSpot, right: longSpot) -> Bool {
    return approxEqual(left.long, right.long, ParkingSpot.epsilon)
}

func <(left: latSpot, right: latSpot) -> Bool {
    return approxLessThan(left.lat, right.lat, ParkingSpot.epsilon)
}

func ==(left: latSpot, right: latSpot) -> Bool {
    return approxEqual(left.lat, right.lat, ParkingSpot.epsilon)
}

class longSpot: ParkingSpot, Comparable { }

class latSpot: ParkingSpot, Comparable {
    func asLongSpot() -> longSpot {
        return longSpot(self.coordinate)
    }
}



let spotsByLat = Node<latSpot>.Leaf
let spotsByLong = Node<longSpot>.Leaf

func getSpots(spotsByLat: Node<longSpot>,
              spotsByLong: Node<latSpot>,
              upperLeft: CLLocationCoordinate2D,
              lowerRight: CLLocationCoordinate2D) -> Set<ParkingSpot> {
    
    let upperLeftSpot = ParkingSpot(upperLeft)
    let lowerRightSpot = ParkingSpot(lowerRight)
    let spotsInXRange = spotsByLat.valuesBetween(upperLeftSpot as! longSpot,
                                             and: lowerRightSpot as! longSpot)
    return spotsByLong.valuesBetween(upperLeftSpot as! latSpot,
                                and: lowerRightSpot as! latSpot,
                                if: {spotsInXRange.contains($0.asLongSpot())})
}

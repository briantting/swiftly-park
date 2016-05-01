//
//  ParkingSpot.swift
//  park
//
//  Created by Ethan Brooks on 4/26/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation
import MapKit

class ParkingSpot: MKPointAnnotation, Comparable {
    var pinColor: UIColor
    let lat: Double
    let long: Double
    
    // note any attempt to compare these will throw an exception unless inheriting class establishes a value
    var value: Double? = nil
    static let epsilon: Double = 5
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.long = coordinate.latitude
        self.lat = coordinate.longitude
        self.pinColor = UIColor.brownColor()
        super.init()
        self.coordinate = coordinate
    }
}


func <(left: ParkingSpot, right: ParkingSpot) -> Bool {
    return right.value! - left.value! > ParkingSpot.epsilon
}

func ==(left: ParkingSpot, right: ParkingSpot) -> Bool {
    return abs(left.value! - right.value!) < ParkingSpot.epsilon
}

class longSpot: ParkingSpot {
    override init(_ coordinate: CLLocationCoordinate2D) {
        super.init(coordinate)
        self.value = coordinate.longitude
    }
}

class latSpot: ParkingSpot {
    override init(_ coordinate: CLLocationCoordinate2D) {
        super.init(coordinate)
        self.value = coordinate.latitude
    }
    
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

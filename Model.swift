//
//  Model.swift
//  park
//
//  Created by Ethan Brooks on 5/2/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation
import MapKit

/**
 A protocol (interface) for handling requests for getting parking spots and updating parking spots
 */
protocol Model {
<<<<<<< HEAD
    func getSpots(upperLeft: CLLocationCoordinate2D,
       _ lowerRight: CLLocationCoordinate2D) -> Set<ParkingSpot>
    mutating func addSpot(coordinate: CLLocationCoordinate2D)
=======
    func spotsWithinView(upperLeft: CLLocationCoordinate2D,
                         _ lowerRight: CLLocationCoordinate2D) -> Set<ParkingSpot>
    mutating func addSpot(coordinate: CLLocationCoordinate2D)
    mutating func removeSpotNear(coordinate: CLLocationCoordinate2D,
                                 radius: Double)
>>>>>>> 31925fbf7e5537802f700fcc384d32132947a02f
}
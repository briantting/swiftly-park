//
//  Model.swift
//  park
//
//  Created by Ethan Brooks on 5/2/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation
import MapKit

protocol Model {
    func getSpots(upperLeft: CLLocationCoordinate2D,
       _ lowerRight: CLLocationCoordinate2D) -> Set<ParkingSpot>
    mutating func addSpot(coordinate: CLLocationCoordinate2D)
}
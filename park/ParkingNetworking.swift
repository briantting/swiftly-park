//
//  ParkingNetworking.swift
//  park
//
//  Created by Brendon Lavernia on 5/3/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation
import MapKit

/**
 A protocol for using a network to get Parking spots and post parking spots
 */
protocol ParkingNetworking {
    static func getParkingSpots(upperLeft: CLLocationCoordinate2D, _ lowerRight: CLLocationCoordinate2D, completionHandler: (parkingSpots : Set<ParkingSpot>) -> ()) -> Void 
    static func postParkingSpot(coordinate : CLLocationCoordinate2D, _ addSpot : Bool) -> Void
    
}
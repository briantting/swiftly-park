//
//  Controller.swift
//  park
//
//  Created by Ethan Brooks on 5/2/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation


protocol MapViewController {
    func getSpots() -> Set<ParkingSpot>
}

protocol LocationController {
    func updateModelWith(location: CLLocationCoordinate2D)
}
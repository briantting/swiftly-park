//
//  MapView.swift
//  park
//
//  Created by Ethan Brooks on 5/1/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    public func setView(center: CLLocationCoordinate2D, diameter: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(
            center, diameter, diameter)
        self.setRegion(coordinateRegion, animated: true)
    }
    
    
}
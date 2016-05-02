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
    
    func setView(center: CLLocationCoordinate2D, diameter: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(
            center, diameter, diameter)
        self.setRegion(coordinateRegion, animated: true)
    }
    
    // gets map bounds
    func getMapBounds() -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
        let region = self.region
        let center = region.center
        let span = region.span
        let half_height = span.latitudeDelta/2
        let half_width = span.longitudeDelta/2
        let upperLeft = CLLocationCoordinate2D(latitude: center.latitude + half_height, longitude: center.longitude - half_width)
        let lowerRight = CLLocationCoordinate2D(latitude: center.latitude - half_height, longitude: center.longitude + half_width)
        return (upperLeft, lowerRight)
    }
    
}

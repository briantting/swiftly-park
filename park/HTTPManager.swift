//
//  HTTPManager.swift
//  park
//
//  Created by Brendon Lavernia on 4/29/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation
import MapKit

class HTTPManager {
    
    // Sets up the URL session
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    // Will do the requesting and fetching of data
    var task: NSURLSessionDataTask?
    
    func getParkingSpots(mapView : MKMapView) -> Void {
        
        let bounds : MKMapRect = mapView.visibleMapRect
        let south = MKMapRectGetMaxY(bounds)
        let north = MKMapRectGetMinY(bounds)
        let west = MKMapRectGetMinX(bounds)
        let east = MKMapRectGetMaxX(bounds)
        let northWest = MKCoordinateForMapPoint(MKMapPoint(x: west, y: north))
        let southEast = MKCoordinateForMapPoint(MKMapPoint(x: east, y: south))
        
        let westBound = northWest.longitude.description
        let eastBound = southEast.longitude.description
        let northBound = northWest.latitude.description
        let southBound = southEast.latitude.description
        
        
        print("north: \(north.description)")
        print("south: \(south.description)")
        
        
        print("West bound: \(westBound)")
        print("East bound: \(eastBound)")
        print("North bound: \(northBound)")
        print("South bound: \(southBound)")
        
        
        
        // Checks if task is already running. Cancels to avoid multiple requests.
        if task != nil {
            task?.cancel()
        }
        let request = "icecream"
        let url = NSURL(string: "http://127.0.0.1:3000/\(request)")
        // 5
        task = session.dataTaskWithURL(url!) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let content = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print(content!)
                }
            }
        }
        // Starts task
        task?.resume()
    }
    
}


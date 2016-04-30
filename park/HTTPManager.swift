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
    
    func getParkingSpots(upperLeft: CLLocationCoordinate2D, _ lowerRight: CLLocationCoordinate2D) -> Void {
        print(upperLeft)
        print(lowerRight)
        
        // Checks if task is already running. Cancels to avoid multiple requests.
        if task != nil {
            task?.cancel()
        }
        let request = "icecream"
        let url = NSURL(string: "http://158.130.104.33:3000/\(request)")
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


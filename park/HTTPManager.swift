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
    var spots = [ParkingSpot]()
    
    func getParkingSpots(upperLeft: CLLocationCoordinate2D, _ lowerRight: CLLocationCoordinate2D) -> [ParkingSpot] {
        print(upperLeft)
        print(lowerRight)
        
        // Checks if task is already running. Cancels to avoid multiple requests.
        if task != nil {
            task?.cancel()
        }
        let request = "37.336325160217136,-122.03684589313772,37.327314839782836,-122.02551410686232"
        let url = NSURL(string: "http://127.0.0.1:3000/\(request)")
        // 5
        task = session.dataTaskWithURL(url!) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let content = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("The server's reply: \(content!)")
                    if content?.length > 0 {
                        self.spots = self.convertStringToParkingSpots(content!)
                    }
                }
            }
        }
        // Starts task
        task?.resume()
        
        return self.spots
    }
    
    func convertStringToParkingSpots(serverString : NSString) -> [ParkingSpot] {
        let coordinateList = serverString.componentsSeparatedByString(",")
        var latitudes = [Double]()
        var longitudes = [Double]()
        print(coordinateList)
        for (index, element) in coordinateList.enumerate() {
            if index % 2 == 0 {
                latitudes.append(Double(element)!)
            } else {
                longitudes.append(Double(element)!)
            }
        }
        
        let spots = latitudes.enumerate().map ({ParkingSpot(CLLocationCoordinate2D(latitude: latitudes[$0.index], longitude: longitudes[$0.index]))})
        
        return spots
    }
    
}


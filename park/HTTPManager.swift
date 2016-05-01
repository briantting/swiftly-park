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
        // Checks if task is already running. Cancels to avoid multiple requests.
        if task != nil {
            task?.cancel()
        }
        let request = convertCoordinateToString(upperLeft, lowerRight)
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
        //Need to wait for task to complete
        sleep(1)
        
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
    
    func postParkingSpot(coordinate : CLLocationCoordinate2D, addSpot : Bool) -> Void {
        if task != nil {
            task?.cancel()
        }
        let request = convertCoordinateToString(coordinate, addSpot)
        let url = NSURL(string: "http://127.0.0.1:3000/\(request)")
        let postURL = NSMutableURLRequest(URL: url!)
        postURL.HTTPMethod = "POST"
        task = session.dataTaskWithRequest(postURL) {
            data, response, error in
            guard data != nil && response != nil && error == nil else {
                print(error.debugDescription)
                return
            }
            
        }
        
        task?.resume()
        
    }
    
    func convertCoordinateToString(coordinate : CLLocationCoordinate2D, _ addSpot : Bool) -> String {
        var stringCoordinate = String("")
        if addSpot {
            stringCoordinate += "ADD,"
        } else {
            stringCoordinate += "REMOVE,"
        }
        stringCoordinate += String(coordinate.latitude)
        stringCoordinate += ","
        stringCoordinate += String(coordinate.longitude)
        
        return stringCoordinate
        
    }
    
    func convertCoordinateToString(coordinate1 : CLLocationCoordinate2D, _ coordinate2 : CLLocationCoordinate2D) -> String {
        var stringCoordinate = String("")
        stringCoordinate += String(coordinate1.latitude)
        stringCoordinate += ","
        stringCoordinate += String(coordinate1.longitude)
        stringCoordinate += ","
        stringCoordinate += String(coordinate2.latitude)
        stringCoordinate += ","
        stringCoordinate += String(coordinate2.longitude)
        print(stringCoordinate)
        return stringCoordinate
        
    }
    
}


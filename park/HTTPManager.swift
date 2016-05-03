//
//  HTTPManager.swift
//  park
//
//  Created by Brendon Lavernia on 4/29/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.

import Foundation
import MapKit


/**
 Handles connecting to the server to get and post parking spot data
 Creates background threads for connecting with the server
 Change ipAddress (without touching port 3000) to address server is running on.
 
 - author:
 Brendon Lavernia
 */
class HTTPManager : ParkingNetworking {
    static let ipAddress = "http:localhost:3000/"
    
    // Sets up the URL session
    static let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    static var getTask : NSURLSessionDataTask? // Request data from model
    static var postTask : NSURLSessionDataTask? // Posts data to model

    /**
     Requests a set of ParkingSpot objects from the server given the current mapView bounds
     
     - parameters:
        - upperLeft: The Northwest corner coordinate of the mapView
        - lowerRight: The Southeast corner coordinate of the mapView
        - completionHandler: A closure that specifies where to store the Set of ParkingSpot objects
     
     Opens a NSURLSession in a background thread
     The Set of ParkingSpot objects are stored using the passed in closure
    */
    class func getParkingSpots(upperLeft: CLLocationCoordinate2D, _ lowerRight: CLLocationCoordinate2D, completionHandler: (parkingSpots : Set<ParkingSpot>) -> ()) -> Void {
        
        // Checks if task is already running. Cancels to avoid multiple requests.
        if getTask != nil {
            getTask?.cancel()
        }
        //Builds request message
        let request = HTTPManager.convertBoundCoordinateToString(upperLeft, lowerRight)
        
        //Builds url
        let url = NSURL(string: "\(ipAddress)\(request)")
        
        //Sets the task instructions once the thread is resumed
        getTask = session.dataTaskWithURL(url!) {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let content = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("The server's reply: \(content!)")
                    if content?.length > 0 {
                        let spots = self.convertStringToParkingSpots(content!)
                        completionHandler(parkingSpots: spots)
                    }
                }
            }
        }
        // Starts task in background thread
        getTask?.resume()
        
    }
    
    /**
     Converts a string filled with Parking Spot locations and returns a set of ParkingSpot objects
     
     - returns:
     A set of ParkingSpot objects
     
     - parameters: 
        - serverString: Takes a string returned by the Model
     */
    class func convertStringToParkingSpots(serverString : NSString) -> Set<ParkingSpot> {
        let coordinateList = serverString.componentsSeparatedByString(",")
        var latitudes = [Double]()
        var longitudes = [Double]()
        
        //Converts the string two arrays of latitudes and longitudes
        for (index, element) in coordinateList.enumerate() {
            if index % 2 == 0 {
                latitudes.append(Double(element)!)
            } else {
                longitudes.append(Double(element)!)
            }
        }
        
        //Iterates through the latitudes and longitudes and stores them in an Array of spots
        let spots = latitudes.enumerate().map({
            ParkingSpot(CLLocationCoordinate2D(latitude: latitudes[$0.index], longitude: longitudes[$0.index]))
        })
        
        let setOfSpots = Set(spots)
        
        return setOfSpots
    }
    
    /**
     Stores or removes the specififed parking spot from the model
     
     - parameters:
        - coordinate: the parking spot
        - addSpot: True if adding spot, false if removing spot from model
     
     Opens a NSURLSession in a background thread
     */
    class func postParkingSpot(coordinate : CLLocationCoordinate2D, _ addSpot : Bool) -> Void {
        if self.postTask != nil {
            self.postTask?.cancel()
        }
        let request = HTTPManager.convertCoordinateToString(coordinate, addSpot)
        let url = NSURL(string: "\(ipAddress)\(request)")
        let postURL = NSMutableURLRequest(URL: url!)
        postURL.HTTPMethod = "POST"
        postTask = session.dataTaskWithRequest(postURL) {
            data, response, error in
            guard data != nil && response != nil && error == nil else {
                print(error.debugDescription)
                return
            }
        }
        // Starts task in background thread
        postTask?.resume()
    }
    
    /**
     Converts a coordinate to a String
     
     - returns:
     A string representing a CLLocationCoordinate2D
     
     - parameters:
        - coordinate: The coordinate to translate into a string
        - addSpot: True if the coordinate will be added to the Model, false if it will be removed from the Model
     
     An example return would be "ADD,39.342134,-130.3421321" or "REMOVE,34.432213,21.34123"
     */
    class func convertCoordinateToString(coordinate : CLLocationCoordinate2D, _ addSpot : Bool) -> String {
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
    
    /**
     Converts the coordinate bounds of a map to a string
     
     - returns:
     A single string representing the coordinate bounds of a map
     
     - parameters:
        - coordinate1: the first coordinate to convert
        - coordinate2: the second coordinate to convert
     
     */
    class func convertBoundCoordinateToString(coordinate1 : CLLocationCoordinate2D,
                                              _ coordinate2 : CLLocationCoordinate2D) -> String {
        var stringCoordinate = String("")
        stringCoordinate += String(coordinate1.latitude)
        stringCoordinate += ","
        stringCoordinate += String(coordinate1.longitude)
        stringCoordinate += ","
        stringCoordinate += String(coordinate2.latitude)
        stringCoordinate += ","
        stringCoordinate += String(coordinate2.longitude)
        
        return stringCoordinate
    }
    
}
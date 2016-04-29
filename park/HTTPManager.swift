//
//  HTTPManager.swift
//  park
//
//  Created by Brendon Lavernia on 4/29/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation

class HTTPManager {
    
    // Sets up the URL session
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    // Will do the requesting and fetching of data
    var task: NSURLSessionDataTask?
    
    init() {
        
    }
    func getParkingSpots() -> Void {
        
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


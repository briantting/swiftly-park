/**
 * File: main.swift
 * Desc: Currently testing a basic HTTP server using Swift
 * Auth: Cezary Wojcik
 * Modified by: Brendon Lavernia
 */

// ---- [ includes ] ----------------------------------------------------------

include "settings.swift"
include "lib/server.swift"
include "../park/ParkingSpot.swift"
include "../park/Tree.swift"

// ---- [ imports ] ----------------------------------------------------------

import Darwin
import Foundation
import MapKit


// ---- [ Process Get Command ] ------------------------------------------------------
func processGetCommand(msg : String, _ parkingSpots : ParkingSpots) -> String {
    print("GET Command: Here is what is in the binary trees")
    print("XTree: \(parkingSpots.spotsByX)")
    print("YTree: \(parkingSpots.spotsByY)")
    let coordinates = convertStringToSpots(msg)
    guard coordinates.count == 2 else {
        return String("Invalid Get Request")
    }
    let northWest = coordinates[0]
    let southEast = coordinates[1]
    let spotsWithinMap = parkingSpots.getSpots(northWest, southEast)
    return convertSpotsToString(spotsWithinMap)
}

// ---- [ Process Post Command ] ------------------------------------------------------
func processPostCommand(msg : String, inout _ parkingSpots : ParkingSpots) -> Void {
    let commandIndex = msg.indexOf(",")
    let command = msg[0..<commandIndex]
    let stringCoordinates = msg[commandIndex+1..<msg.characters.count]
    let coordinates = convertStringToSpots(stringCoordinates)
    
    print("The tree beforePOST command: ")
    print("XTree: \(parkingSpots.spotsByX)")
    print("YTree: \(parkingSpots.spotsByY)")
    
    if command == "ADD" {
        print("POST ADD MESSAGE")
        for coordinate in coordinates {
            parkingSpots.addSpot(coordinate)
        }
    } else if command == "REMOVE" {
        print("POST REMOVE MESSAGE")
        for coordinate in coordinates {
            parkingSpots.removeSpotNear(coordinate, radius: 5)
        }
    }
    else {
        print("Invalid POST command")
    }
    
    print("The tree after POST command: ")
    print("XTree: \(parkingSpots.spotsByX)")
    print("YTree: \(parkingSpots.spotsByY)")
    
    
}

// ---- [ Adapters for networking and binary trees] ------------------------------------------------------

func convertSpotsToString(spots : Set<ParkingSpot>) -> String {
    var stringSpots = ""
    
    guard spots.count > 0 else {
        return stringSpots
    }
    
    for spot in spots {
        
        //Look into fixing order
        stringSpots += String(spot.lat)
        stringSpots += ","
        stringSpots += String(spot.long)
        stringSpots += ","
    }
    stringSpots = stringSpots[0..<stringSpots.characters.count-1]
    return stringSpots
}

func convertStringToSpots(msg : String) -> [CLLocationCoordinate2D] {
    let coordinateList = msg.componentsSeparatedByString(",")
    var latitudes = [Double]()
    var longitudes = [Double]()
    for (index, element) in coordinateList.enumerate() {
        if index % 2 == 0 {
            latitudes.append(Double(element)!)
        } else {
            longitudes.append(Double(element)!)
        }
    }
    
    let spots = latitudes.enumerate().map ({CLLocationCoordinate2D(latitude: latitudes[$0.index], longitude: longitudes[$0.index])})
    print(spots)
    
    return spots
}

// ---- [ Populate trees with default parking spots ] ------------------------------------------------------

func setupDefaultParkingSpots(inout parkingSpots : ParkingSpots) -> Void {
    let appleCampus = CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118)
    let ducati = CLLocationCoordinate2D(latitude: 37.3276574, longitude: -122.0350399)
    let bagelStreetCafe = CLLocationCoordinate2D(latitude: 37.3315193, longitude: -122.0327043)
    
    let locations = [appleCampus, ducati, bagelStreetCafe]
    
    for location in locations {
        parkingSpots.addSpot(location)
    }
    return
}

// ---- [ server setup ] ------------------------------------------------------

let app = Server(port: port)
var parkingSpots = ParkingSpots()

print("Running server on port \(port)")
setupDefaultParkingSpots(&parkingSpots)

app.run() {
    request, response -> () in
    // get and display client address
    guard let clientAddress = request.clientAddress() else {
        print("clientAddress() failed.")
        return
    }
    print("Client IP: \(clientAddress)")
    
    // print request headers
    //print(request.rawHeaders)
    
    let responseMsg : String
    
    if request.isInvalidRequest {
        responseMsg = "Invalid request"
    }
    else if request.isGetCommand {
        responseMsg = processGetCommand(request.commandMsg, parkingSpots)
    } else {
        processPostCommand(request.commandMsg, &parkingSpots)
        responseMsg = "Post successful"
    }
    response.sendRaw("HTTP/1.1 200 OK\n\n\(responseMsg)")
}



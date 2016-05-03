/**
 * File: http.swift
 * Desc: Various HTTP constructs.
 * Auth: Cezary Wojcik
 */

// ---- [ includes ] ----------------------------------------------------------

include "lib/utils.swift" // for String extension

// ---- [ structs ] -----------------------------------------------------------
/**
 Represents a HTTPRequest from an user's phone
 */
struct HTTPRequest {
    let cs : ClientSocket
    let raw : String
    let rawHeaders : [String : String]
    let commandMsg : String
    let isGetCommand : Bool
    let isInvalidRequest : Bool
    
    // ---- [ setup ] ---------------------------------------------------------
    
    /**
     The main meat of the HTTPRequest
     
     - parameters:
        - cs: The connected Client Socket
     
     Parses the request that came in from the user and stores in commandMsg
     */
    init(cs : ClientSocket) {
        // temp vars so that struct members can be constant
        var tempRaw = ""
        var tempRawHeaders : [String : String] = [:]
        
        // get request data
        self.cs = cs
        let lines = cs.fetchRequest()
        
        //If empty request, set defaults and exit
        guard lines.count > 1 else {
            self.isGetCommand = false
            self.isInvalidRequest = true
            self.raw = tempRaw
            self.rawHeaders = tempRawHeaders
            self.commandMsg = ""
            return
        }
        
        
        //Get command and message
        let requestMessage = lines[0].componentsSeparatedByString(" ")
        let command = requestMessage[0]
        self.commandMsg = requestMessage[1].stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
        
        
        
        // parse request headers
        for i in 1..<lines.count {
            if lines[i].containsString(":") {
                let contents = lines[i].componentsSeparatedByString(":")
                let headerName = contents[0]
                let headerContent = contents[1]
                tempRawHeaders[headerName] = headerContent
                tempRaw += lines[i]
            }
            
        }
        
        print("Command received: \(command)")
        
        //Initialize fields depending on request
        if command == "GET" {
            isGetCommand = true
            isInvalidRequest = false
        } else if command == "POST" {
            isGetCommand = false
            isInvalidRequest = false
        } else {
            isGetCommand = false
            isInvalidRequest = true
        }
        
        // assign temp vars to the struct members
        raw = tempRaw
        rawHeaders = tempRawHeaders
        
    }
    
    // ---- [ instance methods ] ----------------------------------------------
    
    /**
     Returns the client clientAddress
     
     - returns:
     Returns the client's IP address aka "127.0.0.1"
     */
    func clientAddress() -> String? {
        return cs.clientAddress()
    }
    
}

/**
 Handles sending a response back to the requester
 */
struct HTTPResponse {
    let cs : ClientSocket
    
    // ---- [ instance methods ] ----------------------------------------------
    /**
     Sends a message back across the client socket
     
     - parameters:
        - message: the response message
     */
    func sendRaw(message : String) {
        cs.sendResponse(message)
    }
}

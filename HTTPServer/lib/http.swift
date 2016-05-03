/**
 * File: http.swift
 * Desc: Various HTTP constructs.
 * Auth: Cezary Wojcik
 */

// ---- [ includes ] ----------------------------------------------------------

include "lib/utils.swift" // for String extension

// ---- [ structs ] -----------------------------------------------------------
struct HTTPRequest {
    let cs : ClientSocket
    let raw : String
    let rawHeaders : [String : String]
    let commandMsg : String
    let isGetCommand : Bool
    let isInvalidRequest : Bool
    
    // ---- [ setup ] ---------------------------------------------------------
    
    init(cs : ClientSocket) {
        // temp vars so that struct members can be constant
        var tempRaw = ""
        var tempRawHeaders : [String : String] = [:]
        
        // get request data
        self.cs = cs
        let lines = cs.fetchRequest()
        
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
    
    func clientAddress() -> String? {
        return cs.clientAddress()
    }
    
}

struct HTTPResponse {
    let cs : ClientSocket
    
    // ---- [ instance methods ] ----------------------------------------------
    
    func sendRaw(message : String) {
        cs.sendResponse(message)
    }
}

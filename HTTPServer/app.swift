/**
 * File: main.swift
 * Desc: Currently testing a basic HTTP server using Swift
 * Auth: Cezary Wojcik
 */

// ---- [ includes ] ----------------------------------------------------------

let port = 3000
/**
 * File: server.swift
 * Desc: Basic HTTP server functionality.
 * Auth: Cezary Wojcik
 */

// ---- [ includes ] ----------------------------------------------------------

/**
 * File: socket.swift
 * Desc: Low-level wrappers around POSIX socket APIs.
 * Auth: Cezary Wojcik
 */

// ---- [ imports ] -----------------------------------------------------------

import Darwin
import Foundation
import MapKit

// ---- [ includes ] ----------------------------------------------------------

/**
 * File: utils.swift
 * Desc: Some utility functions
 * Auth: Cezary Wojcik
 */

// ---- [ helper functions ] --------------------------------------------------

@noreturn func fatalError(message : String) {
    print(message)
    let errorCode = errno
    guard let text = String.fromCString(UnsafePointer(strerror(errorCode)))
        else {
        print("\(errorCode): Unknown error.")
        exit(2)
    }
    print("\(errorCode): \(text)")
    exit(2)
}

// ---- [ extensions ] --------------------------------------------------------

extension String {

    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i, limit: self.endIndex)]
    }

    subscript (r: Range<Int>) -> String {
        return String(self.characters[Range(start: self.startIndex.advancedBy(r.startIndex, limit: self.endIndex),
            end: self.startIndex.advancedBy(r.endIndex, limit: self.endIndex))])
    }

    func indexOf(searchString : String) -> Int {
        // TODO: find a better way to do this
        for i in 0..<(self.characters.count - searchString.characters.count) {
            let substring = self[i..<i + searchString.characters.count]
            if searchString == substring {
                return i
            }
        }
        return -1
    }
}

// ---- [ ParkingSpot ] --------------------------------------------------------
class ParkingSpot: MKPointAnnotation {
    //    var pinColor: UIColor
    var lat: Double
    var long: Double
    var x: Double
    var y: Double
    
    static let epsilon: Double = 5
    
    init(_ coordinate: CLLocationCoordinate2D) {
        long = coordinate.latitude
        lat = coordinate.longitude
        let mapPoint = MKMapPointForCoordinate(coordinate)
        x = mapPoint.x
        y = mapPoint.y
        //        self.init(coordinate)
        super.init()
        self.coordinate = coordinate
    }
    
    init(m mapPoint: MKMapPoint) {
        x = mapPoint.x
        y = mapPoint.y
        let coordinate = MKCoordinateForMapPoint(mapPoint)
        lat = coordinate.latitude
        long = coordinate.longitude
        //        self.init(coordinate)
        super.init()
        self.coordinate = coordinate
    }
    
    override var description: String {
        let description = "\(self.lat), \(self.long))"
        return description
    }
}

func approxLessThan(left: Double, _ right: Double, _ epsilon: Double) -> Bool {
    return right - left > epsilon
}

func approxEqual(left: Double, _ right: Double, _ epsilon: Double) -> Bool {
    return abs(left - right) < epsilon
}

func <(left: XSpot, right: XSpot) -> Bool {
    return approxLessThan(left.x, right.x, ParkingSpot.epsilon)
}

func ==(left: XSpot, right: XSpot) -> Bool {
    return approxEqual(left.x, right.x, ParkingSpot.epsilon)
}

func <(left: YSpot, right: YSpot) -> Bool {
    return approxLessThan(left.y, right.y, ParkingSpot.epsilon)
}

func ==(left: YSpot, right: YSpot) -> Bool {
    return approxEqual(left.y, right.y, ParkingSpot.epsilon)
}

class XSpot: ParkingSpot, Comparable { }

class YSpot: ParkingSpot, Comparable {
    func asXSpot() -> XSpot {
        return XSpot(self.coordinate)
    }
}

struct ParkingSpots {
    var spotsByX = Node<XSpot>.Leaf
    var spotsByY = Node<YSpot>.Leaf
    
    mutating func addSpot(coordinate: CLLocationCoordinate2D) {
        spotsByX = spotsByX.insert(XSpot(coordinate))
        spotsByY = spotsByY.insert(YSpot(coordinate))
    }
    
    mutating func addSpot(mapPoint: MKMapPoint) {
        spotsByX = spotsByX.insert(XSpot(m: mapPoint))
        spotsByY = spotsByY.insert(YSpot(m: mapPoint))
    }
    
    func getSpots(upperLeft: CLLocationCoordinate2D,
                  _ lowerRight: CLLocationCoordinate2D) -> Set<ParkingSpot> {
        
        let spotsInXRange = spotsByX.valuesBetween(XSpot(upperLeft),
                                                   and: XSpot(lowerRight))
        return spotsByY.valuesBetween(YSpot(upperLeft),
                                      and: YSpot(lowerRight),
                                      if: {spotsInXRange.contains($0.asXSpot())})
    }
    
    mutating func removeSpot(coordinate: CLLocationCoordinate2D) -> Void {
        spotsByX = spotsByX.remove(XSpot(coordinate))
        spotsByY = spotsByY.remove(YSpot(coordinate))
    }
}



// ---- [ AVL Binary Tree ] --------------------------------------------------------

indirect enum Node<T where T:Comparable, T:Hashable> : CustomStringConvertible {
    case Leaf
    case Tree(Node<T>, T, Node<T>, Int)
    
    var description: String {
        switch self {
        case .Leaf:
            return "_"
        case let Tree(left, v, right, h):
            return "(\(left) \(v)[\(h)] \(right))"
        }
    }
    
    func value() -> T? {
        switch self {
        case let Tree(_, root, _, _): return root
        case .Leaf: return nil
        }
    }
    
    func getLeft() -> Node<T>? {
        switch self {
        case let Tree(l, _, _, _): return l
        case .Leaf: return nil
        }
    }
    
    func getRight() -> Node<T>? {
        switch self {
        case let Tree(_, _, r, _): return r
        case .Leaf: return nil
        }
    }
    
    func height() -> Int {
        switch self {
        case Tree(_, _, _, let height): return height
        case Leaf: return 0
        }
    }
    
    func getHeight(left: Node<T>, _ right: Node<T>) -> Int {
        return max(left.height(), right.height()) + 1
    }
    
    func apply<U>(f: Node<T> -> U,
               onLeftBranchIf condition: Bool) -> U? {
        if case let Tree(left, _, right, _) = self {
            return condition ? f(left) : f(right)
        }
        return nil
    }
    
    func substitute(f: Node<T> -> Node<T>,
                    forLeftBranchIf condition: Bool) -> Node<T>? {
        if case let Tree(left, root, right, _) = self {
            var (left, right) = (left, right)
            if condition {
                left = f(left)
            } else {
                right = f(right)
            }
            return Tree(left, root, right, getHeight(left, right))
        }
        return nil
    }
    
    func insert(value: T) -> Node<T> {
        switch self {
        case let Tree(_, root, _, _):
            return self
                .substitute({$0.insert(value)},
                            forLeftBranchIf: value < root)!
                .rotate()
            
        case Leaf:
            return Tree(Node.Leaf, value, Node.Leaf, 1)
        }
    }
    
    
    func far(left left: Bool, prev: Node<T>? = nil) -> T? {
        switch self {
        case Tree:
            return apply({$0.far(left: left, prev: self)},
                         onLeftBranchIf: left)!
        case Leaf:
            if prev != nil {
                if case let Tree(_, value, _, _) = prev! {
                    return value
                }
            }
        }
        return nil
    }
    
    func removeFar(left left: Bool) -> (Node<T>)? {
        
        switch self {
        case Leaf: return nil
        case let Tree(leftBranch, _, rightBranch, _):
            
            func recursion(branch: Node<T>) -> Node<T> {
                switch branch {
                case Tree: return self
                    .substitute({$0.removeFar(left: left)!},
                                forLeftBranchIf: left)!
                case Leaf:
                    return left ? rightBranch : leftBranch
                }
            }
            
            return self
                .apply(recursion, onLeftBranchIf: left)!
                .rotate()
        }
    }
    
    func remove(value: T) -> Node<T> {
        switch self {
        case let Tree(left, root, right, _):
            if value == root {
                switch right {
                case Tree:
                    let newRoot = right.far(left: true)!
                    let newRight = right.removeFar(left: true)!
                    let newHeight = getHeight(left, newRight)
                    return Tree(left, newRoot, newRight, newHeight)
                        .rotate()
                case Leaf: return left
                }
            } else {
                return self.substitute({$0.remove(value)},
                                       forLeftBranchIf: value < root)!
                    .rotate()
            }
        case Leaf:
            return self;
        }
    }
    
    func rotate() -> Node<T> {
        switch self {
        case Leaf: return Leaf
        case let Tree(leftBranch, _, rightBranch, _):
            switch leftBranch.height() - rightBranch.height() {
            case -1...1:
                return self
            default:
                let leftIsHigher = leftBranch.height() > rightBranch.height()
                let branch = leftIsHigher ? leftBranch : rightBranch
                switch branch {
                case Leaf: return self
                case let Tree:
                    
                    func graft(middleBranch: Node<T>) -> Node<T> {
                        return self.substitute({_ in middleBranch},
                                               forLeftBranchIf: leftIsHigher)!
                    }
                    
                    return branch.substitute({graft($0)},
                                             forLeftBranchIf: !leftIsHigher)!
                }
            }
        }
    }
    
    func valuesBetween(a: T, and b: T,
                       if condition: T->Bool = {_ in true}) -> Set<T> {
        switch self {
        case .Leaf:
            return Set()
        case let Tree(left, root, right, _):
            switch root {
            case a...b:
                let values = [left, right]
                    .map({$0.valuesBetween(a, and: b, if: condition)})
                let s = condition(root) ? Set([root]) : Set()
                return s.union(values[0])
                    .union(values[1])
            default:
                return self.apply({$0.valuesBetween(a, and: b, if: condition)},
                                  onLeftBranchIf: a < root)!
            }
        }
    }
    
    func balanced() -> Bool {
        switch self {
        case Leaf: return true
        case let Tree(leftBranch, _, rightBranch, _):
            return abs(leftBranch.height() - rightBranch.height()) < 2
                && leftBranch.balanced() && rightBranch.balanced()
        }
    }
}

// ---- [ client socket class ] -----------------------------------------------

class ClientSocket {
    let cs : Int32
    var next = -1

    // ---- [ setup ] ---------------------------------------------------------

    init?(socket : Int32) {
        // buffer for client socket
        var len : socklen_t = 0
        var aaddr = sockaddr(sa_len: 0, sa_family: 0,
            sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        // accept client socket
        cs = accept(socket, &aaddr, &len)
        guard cs != -1 else {
            print("accept(...) failed.")
            return nil
        }
        // no sig pipe
        var nosigpipe : Int32 = 1
        setsockopt(cs, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe,
            socklen_t(sizeof(Int32)))
    }

    deinit {
        close(cs)
    }

    // ---- [ instance methods ] ----------------------------------------------

    // get client IP
    func clientAddress() -> String? {
        var addr = sockaddr(), len: socklen_t = socklen_t(sizeof(sockaddr))
        guard getpeername(cs, &addr, &len) == 0 else {
            print("getpeername(...) failed.")
            return nil
        }
        var hostBuffer = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
        guard getnameinfo(&addr, len, &hostBuffer, socklen_t(hostBuffer.count),
            nil, 0, NI_NUMERICHOST) == 0 else {
            print("getnameinfo(...) failed.")
            return nil
        }
        return String.fromCString(hostBuffer)
    }

    // fetch next byte from client socket
    func nextByte() -> Int {
        var buffer = [UInt8](count: 1, repeatedValue: 0)
        next = recv(cs, &buffer, Int(buffer.count), 0)
        return Int(buffer[0])
    }

    // fetch next line from client socket
    func nextLine() -> String? {
        var line = ""
        var n = 0
        repeat {
            n = nextByte()
            line.append(Character(UnicodeScalar(n)))
        } while n > 0 && n != 10 // until either error or newline
        guard n > 0 && !line.isEmpty else {
            return nil
        }
        return line
    }

    // fetch full request from client socket
    func fetchRequest() -> [String] {
        var request : [String] = []
        var line : String?
        while line != "\r\n" { // until empty newline
            line = self.nextLine()
            // TODO: figure out why guard line = self.nextLine() doesn't work
            guard line != nil else {
                break
            }
            request.append(line!)
        }
        return request
    }

    // send response UTF8
    func sendResponse(response : String) {
        var responseData = [UInt8](response.utf8)
        var sent = 0
        while sent < responseData.count {
            let s = send(cs, &responseData + sent,
                responseData.count - sent, 0)
            guard s > 0 else {
                print("send(...) failed.")
                break
            }
            sent += s
        }
    }
}

// ---- [ socket class ] ------------------------------------------------------

class Socket {
    let s : Int32

    // ---- [ setup ] ---------------------------------------------------------

    init(host : String, port : Int) {
        // create socket that clients can connect to
        s = socket(AF_INET, SOCK_STREAM, Int32(0))
        guard self.s != -1 else {
            fatalError("socket(...) failed.")
        }

        // set socket options
        var value : Int32 = 1;
        guard setsockopt(self.s, SOL_SOCKET, SO_REUSEADDR, &value,
            socklen_t(sizeof(Int32))) != -1 else {
            fatalError("setsockopt(...) failed.")
        }

        // bind socket to host and port
        var addr = sockaddr_in(sin_len: __uint8_t(sizeof(sockaddr_in)),
            sin_family: sa_family_t(AF_INET),
            sin_port: Socket.porthtons(in_port_t(port)),
            sin_addr: in_addr(s_addr: inet_addr(host)),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        var saddr = sockaddr(sa_len: 0, sa_family: 0,
            sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        memcpy(&saddr, &addr, Int(sizeof(sockaddr_in)))
        guard bind(self.s, &saddr, socklen_t(sizeof(sockaddr_in))) != -1 else {
            fatalError("bind(...) failed.")
        }

        // begin listening on the socket
        guard listen(s, 20) != -1 else {
            fatalError("listen(...) failed.")
        }
    }

    // ---- [ instance methods ] ----------------------------------------------

    func acceptClientSocket() -> ClientSocket? {
        return ClientSocket(socket: s)
    }

    // ---- [ static methods ] ------------------------------------------------

    private static func porthtons(port: in_port_t) -> in_port_t {
        let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian
        return isLittleEndian ? _OSSwapInt16(port) : port
    }
}
/**
 * File: http.swift
 * Desc: Various HTTP constructs.
 * Auth: Cezary Wojcik
 * Modified: Brendon Lavernia
 */

// ---- [ includes ] ----------------------------------------------------------


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
        
        
        //Get command and message
        let requestMessage = lines[0].componentsSeparatedByString(" ")
        let command = requestMessage[0]
        commandMsg = requestMessage[1][1..<requestMessage[1].characters.count]


        // parse request headers
        for i in 1..<lines.count {
            let index = lines[i].indexOf(":")
            guard index != -1 else {
                continue
            }
            let headerName = lines[i][0..<index]
            let headerContent = lines[i][index+1..<lines[i].characters.count]
            tempRawHeaders[headerName] = headerContent
            tempRaw += lines[i]
        }
        
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

// ---- [ server class ] ------------------------------------------------------

class Server {
    let sock : Socket

    // ---- [ setup ] ---------------------------------------------------------

    init(host : String = "0.0.0.0", port : Int) {
        sock = Socket(host: host, port: port)
    }

    // ---- [ instance methods ] ----------------------------------------------

    func run(closure : (request : HTTPRequest,
        response : HTTPResponse) -> () ) {
        while true {
            // get client socket
            guard let cs = sock.acceptClientSocket() else {
                print("acceptClientSocket() failed.")
                continue
            }

            // get request
            let request = HTTPRequest(cs: cs)

            // create response
            let response = HTTPResponse(cs: cs)

            // run closure
            closure(request: request, response: response)
        }
    }
}


// ---- [ Process Get Command ] ------------------------------------------------------
func processGetCommand(msg : String, _ parkingSpots : ParkingSpots) -> String {
    print("GET Command: Here is what is in the binary trees")
    print(parkingSpots.spotsByX)
    print(parkingSpots.spotsByY)
    let coordinates = convertStringToSpots(msg)
    guard coordinates.count == 2 else {
        return String("Invalid Get Request")
    }
    let northWest = coordinates[0]
    let southEast = coordinates[1]
    let spotsWithinMap = parkingSpots.getSpots(northWest, southEast)
    print(spotsWithinMap.count)
    return convertSpotsToString(spotsWithinMap)
}

// ---- [ Process Post Command ] ------------------------------------------------------
func processPostCommand(msg : String, inout _ parkingSpots : ParkingSpots) -> Void {
    let commandIndex = msg.indexOf(",")
    let command = msg[0..<commandIndex]
    let stringCoordinates = msg[commandIndex+1..<msg.characters.count]
    let coordinates = convertStringToSpots(stringCoordinates)
    
    if command == "ADD" {
        for coordinate in coordinates {
            parkingSpots.addSpot(coordinate)
        }
    } else if command == "REMOVE" {
        for coordinate in coordinates {
            parkingSpots.removeSpot(coordinate)
        }
    }
    else {
        print("Invalid POST command")
    }
    
    print("The tree after POST command: ")
    print(parkingSpots.spotsByX)
    print(parkingSpots.spotsByY)
    
    
}

// ---- [ Adapters for networking and binary trees] ------------------------------------------------------

func convertSpotsToString(spots : Set<ParkingSpot>) -> String {
    var stringSpots = ""
    for spot in spots {
        
        //Look into fixing order
        stringSpots += String(spot.long)
        stringSpots += ","
        stringSpots += String(spot.lat)
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
    print(request.rawHeaders)
    
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
    print(responseMsg)
    response.sendRaw("HTTP/1.1 200 OK\n\n\(responseMsg)")
}


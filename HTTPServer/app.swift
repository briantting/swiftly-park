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
 */

// ---- [ includes ] ----------------------------------------------------------


// ---- [ structs ] -----------------------------------------------------------

struct HTTPRequest {
    let cs : ClientSocket
    let raw : String
    let rawHeaders : [String : String]

    // ---- [ setup ] ---------------------------------------------------------

    init(cs : ClientSocket) {
        // temp vars so that struct members can be constant
        var tempRaw = ""
        var tempRawHeaders : [String : String] = [:]

        // get request data
        self.cs = cs
        let lines = cs.fetchRequest()

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

// ---- [ server setup ] ------------------------------------------------------

let app = Server(port: port)

print("Running server on port \(port)")

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
    response.sendRaw("HTTP/1.1 200 OK\n\nHello, World!\n")
}


## Swiftly Park                                        
### Authors
#### Ethan Brooks
#### Brendon Lavernia 
#### Brian Ting 

### Summary
Swifty Park is a Swift application for iOS that helps users find parking spots. The application interface is a map with various pins representing available parking spots. Available parking spots are continually pulled from the server which stores them in binary search trees sorted by coordinate. As the user moves or alters the map view, the map is updated accordingly. Available or taken parking spots are determined automatically based on user location and speed and the updated spot is pushed to the server.


Interfaces
* Model: `ParkingSpots`, a class that represents our underlying database, implements the model interface.
* ParkingNetworking: A protocol for connecting from the Phone to server. 
* Apple’s various swift interfaces: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
Design Patterns
* Observer: viewController implements the Observer design pattern by implementing the `CLLocationManagerDelegate` and `MKMapViewDelegate` protocols and by assigning `self` as the delegate for `mapView` and `locationManager`. This enables the viewController to listen to two events
⋅⋅⋅⋅* Changes in the map view (which call the `mapView` function).
⋅⋅⋅⋅* Updates to the user’s location (which call the `locationManager` function).
* Model - View - Controller (MVC)
⋅⋅⋅⋅* Model: The ParkingSpots struct implements the Model protocol. It stores all the parking spots in two AVL Binary Trees (one for latitudes, one for longitudes).
⋅⋅⋅⋅* Controller: The ViewController class handles responses made by the View (map view changes) as well as the model (parking spot updates).
⋅⋅⋅⋅* View: The Main.storyboard holds the app’s view. 

### Data Structures
* AVL Binary Search Tree (Tree.swift)
* Sets
* Arrays

### Graphics (iOS development)
* UI Kit
* Map Kit

### Advanced Topics (iOS development)
* Swift - Project programming language
* XCode - Project integrated development environment
* iOS development
* GPX - Route files to simulate user location and speed
* Networking - Server
* Closures
* Class Extensions
* Functional Programming

### Usage
* Load the XCode Project
* Set the Simulator’s Route
⋅⋅⋅⋅* Product -> Scheme -> Edit Scheme -> Run -> Options -> Default Location -> MassPark.gpx or Add GPX File to Project
* Open Terminal to Navigate to Project Folder and Run Server
⋅⋅⋅⋅* Type “cd HTTPServer/”
⋅⋅⋅⋅* Type “make run”
⋅⋅⋅⋅* Change the IP in HTTPManager.swift as necessary (for remote access)
* Run the XCode Project
* Enjoy

### Work Breakdown
We all contributed to the overall project effort, but our specific responsibilities and tasks included:
⋅⋅⋅⋅Brendon wrote the part of the program responsible for the flow of data between the model and view controller. Specifically, implementing the server. Brendon’s focus was on converting String messages to and from ParkingSpot objects and utilizing multithreading to ensure the program did not crash with multiple requests.  
⋅⋅⋅⋅Brian wrote the part of the program responsible for pulling in user location data and determining if a user is parking or unparking. Brian was also responsible for setting up the simulator and creating user routes.
⋅⋅⋅⋅Ethan wrote the part of the program responsible for handling the collection and retrieval of parking spots on the server and their delivery to a maps interface. Specifically, the data structure.

### GitHub
[Public Repo - contains final code, was the repository we worked in](https://github.com/lobachevzky/swiftly-park.git)
[Private Repo - contains final code](https://github.com/cit-upenn/594-s16-project-swiftlypark.git)

### Credit
#### Apple
Thanks for everything.

#### [Google Maps to GPX converter](http://labs.coruscantconsulting.co.uk/garmin/gpxgmap/convert.php) 

#### [GPX to GPX speed converter](https://github.com/appscape/gips) 

#### [Swift Server Skeleton](https://github.com/cezarywojcik/Swift-Server.)
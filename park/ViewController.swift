import UIKit
import CoreLocation
import MapKit

/**
 
 Responsible for updating the contents of the views, usually in response to changes to the underlying data, responding to user interactions with views, and resizing views and managing the layout of the overall interface.
 
 */
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var spots = Set<ParkingSpot>() // set of parking spots
    
    var locationManager: CLLocationManager = CLLocationManager()
    var isDriving: Bool = true // tracks if user is driving
    var prevLocation: CLLocation? = nil // tracks previous location for speed calculation
    var prevSpeed: Double = 5 // tracks previous speed
    
    /**
     
     Called when the application's view is loaded.
     
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        let cupertino = CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118)

        // set parameters of map
        mapView.delegate = self
        mapView.setView(cupertino, diameter: 1000)
        
        // set parameters of location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // updates map every 0.5 seconds
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(ViewController.updateMap), userInfo: nil, repeats: true)
        mapView.tintColor = UIColor.redColor()
    }
    
    /**
     
     Calls updateMap() when the application's map view changes (pan/zoom).
     
    */
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     
     Calls calculatePark() when the application's current location is updated.
     
    */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        calculatePark(latestLocation)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    }
    
    /**
     
     Updates map view annotations by getting parking spots from the server and removing invalid spots while adding new spots.
     
    */
    func updateMap() {

        // populate self.spots with correct spots
        let (upperLeft, lowerRight) = mapView.getMapBounds()
		HTTPManager.getParkingSpots(upperLeft, lowerRight, completionHandler: {parkingSpots in self.spots = parkingSpots})
        
        // spots that are on the map
        let spotsInView = Set(mapView.annotations.filter({$0 is ParkingSpot}).map({$0 as! ParkingSpot}))
        
        // remove parking spots that are not in updatedParkingSpots
        let toRemove = Array(spotsInView.subtract(self.spots))
        for spot in toRemove {
            print("removing", spot)
        }
        mapView.removeAnnotations(toRemove)
        
        // add parking spots that are new in updatedParkingSpots
        let toAdd = Array(self.spots.subtract(spotsInView))
        mapView.addAnnotations(toAdd)
        
        mapView.showsUserLocation = true
    }
    
    /**
     
     Calculates user speed and determines if the user is parking or unparking. Then adds or removes parking spots from the server as necessary in addition to changing current location marker color.
     
     - parameters:
        - latestLocation: User's current position as a CLLocation object.
     
    */
    func calculatePark(latestLocation: CLLocation) {
        
        // calculates speed (m/s) from distance traveled each second
        var speed: Double = prevSpeed
        if prevLocation != nil {
            let tempSpeed: Double = latestLocation.distanceFromLocation(prevLocation!)
            if tempSpeed != 0 {
                speed = tempSpeed
            }
        }
        
        // Park
        if isDriving && speed < 5 {
            isDriving = false
            mapView.tintColor = UIColor.blueColor()
            HTTPManager.postParkingSpot(prevLocation!.coordinate, false)
            print("Parked")
        }
        // Unpark
        else if !isDriving && speed >= 5 {
            isDriving = true
            mapView.tintColor = UIColor.redColor()
            HTTPManager.postParkingSpot(prevLocation!.coordinate, true)
            print("Unparked")
        }
        prevLocation = latestLocation
        prevSpeed = speed
    }
}

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var server: HTTPManager = HTTPManager()

    var isDriving: Bool = true // tracks if user is driving
    var prevLocation: CLLocation? = nil // tracks previous location for speed calculation
    var prevSpeed: Double = 5 // tracks previous speed
    var time: Double = NSDate.timeIntervalSinceReferenceDate() // tracks time
    
    var locationManager: CLLocationManager = CLLocationManager()
    
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // updates on new location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]

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
            server.postParkingSpot(prevLocation!.coordinate, false)
            print("Parked")
        }
        // Unpark
        else if !isDriving && speed >= 5 {
            isDriving = true
            server.postParkingSpot(prevLocation!.coordinate, true)
            print("Unparked")
        }
        // updates every 30 seconds
        if NSDate.timeIntervalSinceReferenceDate() - time > 10 {
            updateMap()
            time = NSDate.timeIntervalSinceReferenceDate()
        }
        
        prevLocation = latestLocation
        prevSpeed = speed
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    }
    
    // updates on new view
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateMap()
    }
    
    // updates annotations
    func updateMap() {
        // removes old parking spots
        mapView.removeAnnotations(mapView.annotations.filter() {$0 !== mapView.userLocation})
        // adds new parking spots
        let (upperLeft, lowerRight) = mapView.getMapBounds()
        let parkingSpots = server.getParkingSpots(upperLeft, lowerRight)

        mapView.showsUserLocation = true
        for spot in parkingSpots {
            mapView.addAnnotation(spot)
        }
    }
}

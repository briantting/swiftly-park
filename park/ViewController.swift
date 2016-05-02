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

        // set parameters of map
        mapView.delegate = self
        let regionDiameter: CLLocationDistance = 1000
        func centerMapOnLocation(location: CLLocationCoordinate2D) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionDiameter, regionDiameter)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        // centers map on default location
        let cupertino = CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118)
        centerMapOnLocation(cupertino)
        
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
        prevLocation = latestLocation
        prevSpeed = speed
        
        // Park
        if isDriving && speed < 5 {
            isDriving = false
            server.postParkingSpot(latestLocation.coordinate, false)
            print("Parked")
        }
        // Unpark
        else if !isDriving && speed >= 5 {
            isDriving = true
            server.postParkingSpot(latestLocation.coordinate, true)
            print("Unparked")
        }
        // updates every 30 seconds
        if NSDate.timeIntervalSinceReferenceDate() - time > 30000 {
            updateMap()
            time = NSDate.timeIntervalSinceReferenceDate()
        }
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
        let (upperLeft, lowerRight) = getMapBounds()
        let parkingSpots = server.getParkingSpots(upperLeft, lowerRight)

        mapView.showsUserLocation = true
        for spot in parkingSpots {
            mapView.addAnnotation(spot)
        }
    }
    
    // gets map bounds
    func getMapBounds() -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
        let region = self.mapView.region
        let center = region.center
        let span = region.span
        let half_height = span.latitudeDelta/2
        let half_width = span.longitudeDelta/2
        let upperLeft = CLLocationCoordinate2D(latitude: center.latitude + half_height, longitude: center.longitude - half_width)
        let lowerRight = CLLocationCoordinate2D(latitude: center.latitude - half_height, longitude: center.longitude + half_width)
        return (upperLeft, lowerRight)
    }
    
}

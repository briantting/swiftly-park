import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var server: HTTPManager!

    var isDriving: Bool = true // tracks if user is driving
    var prevLocation: CLLocation? = nil // tracks previous location for speed calculation
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        server = HTTPManager()
        
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
        let (upperLeft, lowerRight) = getMapBounds()
        server = HTTPManager()
        parkingSpots = server.getParkingSpots(upperLeft, lowerRight)
        
        // set parameters of location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        updateMap()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]

        // calculates speed (m/s) from distance traveled each second
        var speed: Double = 5
        if prevLocation != nil {
            speed = latestLocation.distanceFromLocation(prevLocation!)
        }
        prevLocation = latestLocation
        
        // Park
        if isDriving && speed < 5 {
            isDriving = false
            server.postParkingSpot(latestLocation.coordinate, false)
        }
        // Vacate
        else if !isDriving && speed >= 5 {
            isDriving = true
            server.postParkingSpot(latestLocation.coordinate, true)
        }
        updateMap()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    }
    
    func updateMap() {
        // removes old parking spots
        mapView.removeAnnotations(mapView.annotations.filter() {$0 !== mapView.userLocation})
        // adds new parking spots
        let (upperLeft, lowerRight) = getMapBounds()
        mapView.addAnnotations(server.getParkingSpots(upperLeft, lowerRight))
        
//        // Test
//        let cupertino = CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118)
//        mapView.addAnnotation(ParkingSpot(cupertino))
    }
    
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
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateMap()
        
    }
    
}

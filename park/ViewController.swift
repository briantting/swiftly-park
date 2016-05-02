import UIKit
import CoreLocation
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var server: HTTPManager = HTTPManager()

    var isDriving: Bool = true // tracks if user is driving
    var prevLocation: CLLocation? = nil // tracks previous location for speed calculation
    
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
        
        
        print("NSTimer")
        //        _ = NSTimer
        //            .scheduledTimerWithTimeInterval(1,
        //                                            target: self,
        //                                            selector: #selector(ViewController.testPrint),
        //                                            userInfo: nil,
        //                                            repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // updates on new location
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
//            server.postParkingSpot(latestLocation.coordinate, false)
        }
        // Vacate
        else if !isDriving && speed >= 5 {
            isDriving = true
//            server.postParkingSpot(latestLocation.coordinate, true)
        }
        updateMap()
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
        mapView.removeAnnotations(mapView.annotations.filter()
            {$0 !== mapView.userLocation})
        // adds new parking spots
        let (upperLeft, lowerRight) = mapView.getMapBounds()
        mapView.addAnnotations(server.getParkingSpots(upperLeft, lowerRight))
    }
}

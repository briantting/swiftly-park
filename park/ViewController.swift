import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var isDriving: Bool = true // tracks if user is driving
    var prevLocation: CLLocation? = nil // tracks previous location for speed calculation
    var prevSpeed: Double = 5 // tracks previous speed
    var spots = Set<ParkingSpot>()
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
        
        // updates map every 5 seconds
        NSTimer.scheduledTimerWithTimeInterval(5,
                                               target: self,
                                               selector: #selector(ViewController.updateMap),
                                               userInfo: nil,
                                               repeats: true)
		mapView.tintColor = UIColor.redColor()
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
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    }
    
    // updates on new view
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateMap()
    }
    
    // updates annotations
    func updateMap() {
        
        // populate self.spots with correct spots
        let (upperLeft, lowerRight) = mapView.getMapBounds()
		HTTPManager.getParkingSpots(upperLeft, lowerRight, completionHandler: {parkingSpots in
            self.spots = parkingSpots
        })
        
        // spots that are on the map
        let spotsInView = Set(mapView.annotations
            .filter({$0 is ParkingSpot}).map({$0 as! ParkingSpot}))
        
        // remove parking spots that are not in updatedParkingSpots
        let toRemove = Array(spotsInView.subtract(self.spots))
        for spot in toRemove {
            print("removing", spot)
//            mapView.removeAnnotation(spot)
        }
        mapView.removeAnnotations(toRemove)
        
        // add parking spots that are new in updatedParkingSpots
        let toAdd = Array(self.spots.subtract(spotsInView))
        mapView.addAnnotations(toAdd)
        
        mapView.showsUserLocation = true
    }
}

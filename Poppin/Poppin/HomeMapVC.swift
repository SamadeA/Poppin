
import UIKit
import MapKit
import Firebase
import FirebaseDatabase

//===================
//class ColorPointAnnotation: MKPointAnnotation {
//    var pinColor: UIColor
//
//    init(pinColor: UIColor) {
//        self.pinColor = pinColor
//        super.init()
//    }
//}

class HomeMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    
    var ref: DatabaseReference!
    let id = Auth.auth().currentUser?.uid
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    let locationManager = CLLocationManager()
    let newPin = MKPointAnnotation()


    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        ref = Database.database().reference()
        displayOtherUsers()
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       let locationValue = manager.location?.coordinate
        let location = locations.last! as CLLocation
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        newPin.coordinate = location.coordinate
        mapView.addAnnotation(newPin)
    }
    
    @IBAction func poppinButton(_ sender: Any) {
        guard let id = id else {
            print("id was nil");return
        }
        guard let latitude = latitude else {
            print("lat was nil");return
        }
        guard longitude != nil else {
            print("longitude was nil");return
        }
        self.ref.child("user").child(id).child("latitude").setValue(latitude)
        self.ref.child("user").child(id).child("longitude").setValue(longitude)
    }
    
    func displayOtherUsers() {
        
        ref.child("user").observe(.value) {
            (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                for (_, coordinateDict) in dict {
                    if let coordinates = coordinateDict as? [String: CLLocationDegrees],
                        let lat = coordinates["latitude"],
                        let lon = coordinates["longitude"] {
                        print("lat: ", lat, "lon: ", lon, "<<<")
                        DispatchQueue.main.async {
                            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                            
                             let newPin = MKPointAnnotation()
                            self.mapView.setRegion(region, animated: true)
                            newPin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            
                            self.mapView.addAnnotation(self.newPin)
                            //=======================
//                            let annotation = ColorPointAnnotation(pinColor: .blue)
//                            annotation.coordinate = center
//                            self.mapView.addAnnotation(annotation)
                        }
                    }
                }
            }
        }
    }
    //===========================
    class Annotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        var custom_image: Bool = true
        var color: MKPinAnnotationColor = .purple
    }

    @IBAction func signoutButton(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Goodbye!")
            navigationController?.popViewController(animated: true)
        } catch let error {
            print("Error while signin out: %@", error)
        }
        dismiss(animated: true)
    }
//===================================
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            return nil
//        }
//        let reuseId = "pin"
//        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
//        if pinView == nil {
//            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            let colorPointAnnotation = annotation as! MKShape
//            pinView?.pinTintColor = MKShape.pinColor
//        } else {
//            pinView?.annotation = annotation
//        }
//        return pinView
//    }
    
}



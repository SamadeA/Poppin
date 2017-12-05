
import UIKit
import MapKit
import Firebase
import FirebaseDatabase

//1======================================================
class ColorPointAnnotation: MKPointAnnotation {
    var pinColor: UIColor

    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}

class HomeMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    
    var ref: DatabaseReference!
    let id = Auth.auth().currentUser?.uid
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    let locationManager = CLLocationManager()
    let newPin = MKPointAnnotation()
//    var pinTinColor: UIColor

//2==========================
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //Search bar to self
        searchBar.delegate = self
        ref = Database.database().reference()
        displayOtherUsers()
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            //To let the map move manually
            locationManager.stopUpdatingLocation()
        
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
                            //1=======================================
                            let annotation = ColorPointAnnotation(pinColor: .blue)
                            annotation.coordinate = center
                            self.mapView.addAnnotation(annotation)
                        }
                    }
                }
            }
        }
    }
    //1===========================
    class Annotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        var custom_image: Bool = true
        var color: MKPinAnnotationColor = .purple
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchBar.text!) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                let placemark = placemarks?.first
                let anno = MKPointAnnotation()
                anno.coordinate = (placemark?.location?.coordinate)!
                anno.title = self.searchBar.text!
                
                self.mapView.addAnnotation(anno)
                self.mapView.selectAnnotation(anno, animated: true)
                
            }else{
                print(error?.localizedDescription ?? "error")
            }
            
        }
        print("Searching...", searchBar.text!)
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
    
   
    
//1================================================================
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            //Pin drop snimste line is below
//            pinView!.animatesDrop = true
            let colorPointAnnotation = annotation as! MKShape
//            pinView?.pinTintColor = MKShape.pinColor
            
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    

//3===============================
//This func is for a deatil view however, it did not worked
//    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
//        if let annotation = annotation as? MKAnnotationView {
//            let identifier = "pin"
//            var view: MKPinAnnotationView
//            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//                as? MKPinAnnotationView { // 2
//                dequeuedView.annotation = annotation as! MKAnnotation
//                view = dequeuedView
//            } else {
//                // 3
//                view = MKPinAnnotationView(annotation: annotation as! MKAnnotation, reuseIdentifier: identifier)
//                view.canShowCallout = true
//                view.calloutOffset = CGPoint(x: -5, y: 5)
//                let button = UIButton(type:.detailDisclosure)
//                view.rightCalloutAccessoryView = button as UIView
//            }
//            return view
//        }
//        return nil
//    }
}
    




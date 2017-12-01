//
//  HomeMapVC.swift
//  Poppin
//
//  Created by AbdulSamade on 11/27/17.
//  Copyright © 2017 AbdulSamade. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase


class HomeMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet var SearchBar: UISearchBar!
    
    var ref: DatabaseReference!
    let id = Auth.auth().currentUser?.uid
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    let locationManager = CLLocationManager()
    
    let newPin = MKPointAnnotation()

 
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        displayOtherUsers()
        self.locationManager.requestAlwaysAuthorization()
//        SearchBar.delegate = self
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
        
        print("Location is ", locationValue ?? "nil")
        
        mapView.setRegion(region, animated: true)
        newPin.coordinate = location.coordinate
        mapView.addAnnotation(newPin)
        
        let annotation3 = Annotation()
        annotation3.coordinate = CLLocationCoordinate2D(latitude: 1.0, longitude:  0.0)
        annotation3.custom_image = false
        annotation3.color = MKPinAnnotationColor.green
        mapView.addAnnotation(annotation3)
    }
    
    
    
    
    
    @IBAction func poppinButton(_ sender: Any) {
        guard let id = id else {
            print("id was nil")
            return
        }
        guard let latitude = latitude else {
            print("lat was nil")
            return
        }
        guard let longitute = longitude else {
            print("longitude was nil")
            return
        }
        self.ref.child("user").child(id).child("latitude").setValue(latitude)
        self.ref.child("user").child(id).child("longitude").setValue(longitude)
        
    }
    
    func displayOtherUsers() {
        
        ref.child("user").observe(.value) {
            (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                for (id, coordinateDict) in dict {
                    if let coordinates = coordinateDict as? [String: CLLocationDegrees],
                        let lat = coordinates["latitude"],
                        let lon = coordinates["longitude"] {
                        
                        DispatchQueue.main.async {
                            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                            
                             let newPin = MKPointAnnotation()
                            self.mapView.setRegion(region, animated: true)
                            newPin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            
                            self.mapView.addAnnotation(self.newPin)
                            
                        }
                    }
                }
                
            }
        }
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let annotationView = MKPinAnnotationView()
//        annotationView.pinTintColor = .blue
//        return annotationView
//    }
    
    class Annotation: NSObject, MKAnnotation
    {
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        var custom_image: Bool = true
        var color: MKPinAnnotationColor = MKPinAnnotationColor.purple
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        SearchBar.resignFirstResponder()
//
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(searchBar.text!) { (placemarks:[CLPlacemarks]?, err:Error) in
//            if err == nil {
//                let placemark = placemarks?.first
//                let anno = MKPinAnnotation()
//                anno.coordinate = (placemark?.location?.coordinate)!
//                anno.title = searchBar.text!
//                self.mapView.addAnnotation(anno)
//                self.mapView.selectedAnnotation(anno, animated: true)
//
//            }else{
//                print(error?.localizedDescription ?? "error")
//
//            }
//
//        }
//        print("Searching...", SearchBar.text!)
//
//        UIApplication.shared.beginIgnoringInteractionEvents()
//        let activityIndicator = UIActivityIndicatorView()
//        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//        activityIndicator.center = self.view.center
//         activityIndicator.hidesWhenStopped = true
//         activityIndicator.startAnimating()
//
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchBar.delegate = self
//        present(searchController, animated: true, completion: nil)
//
//        self.addSubview(activityIndicator)
    //    }
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
}



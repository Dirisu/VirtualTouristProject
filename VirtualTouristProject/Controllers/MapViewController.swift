//
//  ViewController.swift
//  VirtualTouristProject
//
//  Created by Marvellous Dirisu on 09/06/2022.
//

//import UIKit
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//}

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
    func dropPin(){
        
            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chosenLocation(gestureRecognizer:)))
            mapView.addGestureRecognizer(gestureRecognizer)
            
            
           
        }
        @objc func chosenLocation(gestureRecognizer : UILongPressGestureRecognizer){
            
            if gestureRecognizer.state == .began {
                let touchedPoint = gestureRecognizer.location(in: self.mapView)
                
                
            // for converting touched point to coordinates
                let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
                
                
                // create a pin
                let annotation = MKPointAnnotation()
                annotation.coordinate = touchedCoordinates
                self.mapView.addAnnotation(annotation)
//                addPin(lat: touchedCoordinates.latitude, long: touchedCoordinates.longitude)
                debugPrint("pin: \(touchedCoordinates.latitude), \(touchedCoordinates.longitude)")
            }
        }
    
}


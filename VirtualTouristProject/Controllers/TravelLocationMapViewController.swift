//
//  ViewController.swift
//  VirtualTouristProject
//
//  Created by Marvellous Dirisu on 09/06/2022.
//


import UIKit
import MapKit
import CoreData

class TravelLocationMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate  {
    
    
    
    var dataController : DataController!
    var fetchedResultsController : NSFetchedResultsController<Pins>!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        setUpFetchResultsController()
//        loadZoomLevel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dropPin()
        setUpFetchResultsController()
        mapView.isUserInteractionEnabled = true
//        saveZoomLevel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    
    func setUpFetchResultsController() {
        
        let fetchRequest: NSFetchRequest<Pins> = Pins.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
                fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Pins")
        
        
        
        fetchedResultsController.delegate = self
        do {
            try? fetchedResultsController.performFetch()
        } catch{
            fatalError("The fetch could not be performed :\(error.localizedDescription)")
        }
        
    }
    
    
  
    
    func dropPin(){
    
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chosenLocation(gestureRecognizer:)))
//        gestureRecognizer.minimumPressDuration = 1
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
            addPin(lat: touchedCoordinates.latitude, long: touchedCoordinates.longitude)
            debugPrint("pin: \(touchedCoordinates.latitude), \(touchedCoordinates.longitude)")
        }
    }
    

    
    func addPin(lat : Double , long : Double){
        let pin = Pins(context: dataController!.viewContext)
        
        pin.latitude = lat
        pin.longitude = long
        pin.creationDate = Date()
        do {
            try dataController?.viewContext.save()
        } catch {
            
            fatalError("Pin cannot be added :\(error.localizedDescription)")
        }
        
        setUpFetchResultsController() //-> after saving the pin, grab pins from core data again so that it includes the new one.
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }


        return pinView
    }
    

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)  // otherwise it always shows same pin. you need to deselect
        
        let latitudeClicked = view.annotation?.coordinate.latitude
        let longitudeClicked = view.annotation?.coordinate.longitude
        
        //Find the clicked pin in Core Data.
        if let pins = fetchedResultsController.fetchedObjects{
            for pin in pins {
                if pin.latitude == latitudeClicked && pin.longitude == longitudeClicked {
                    if let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as? PhotoAlbumViewController {
                        vc.pin = pin
                        vc.dataController = dataController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        fatalError("error!")
                        
                    }
                }
            }
        }
    }
    
    //MARK: for the first time
//    func saveZoomLevel(){
//
//        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: ZoomModel.latitude)
//        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: ZoomModel.longitude)
//        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: ZoomModel.latitudeDelta)
//        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: ZoomModel.longitudeDelta)
//
//    }
    
//    //MARK: if it has launched before
//    func loadZoomLevel(){
//
//        guard let longitude = UserDefaults.standard.object(forKey: ZoomModel.longitude) as? Double else {return}
//        guard let latitude = UserDefaults.standard.object(forKey: ZoomModel.latitude) as? Double else {return}
//        guard let latitudeDelta = UserDefaults.standard.object(forKey: ZoomModel.latitudeDelta) as? Double else {return}
//        guard let longitudeDelta = UserDefaults.standard.object(forKey: ZoomModel.longitudeDelta) as? Double else {return}
//        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
//        let region = MKCoordinateRegion(center: coordinate, span: span)
//        mapView.setRegion(region, animated: true)
//
//
//        //MARK: create a pin objects
//        if let pins = fetchedResultsController.fetchedObjects {
//            for pin in pins {
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
//                mapView.addAnnotation(annotation)
//
//            }
//        }
//
//    }
//
//
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//
//        saveZoomLevel()
//
//    }
//
}

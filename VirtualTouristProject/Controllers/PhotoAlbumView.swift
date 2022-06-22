//
//  PhotoAlbumView.swift
//  VirtualTouristProject
//
//  Created by Marvellous Dirisu on 19/06/2022.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var pin : Pins!
    var photo: [Photos]! = []
    
    var photoArrays = [String]()
    var photosDb: [NSManagedObject] = []
    
    var dataController : DataController!
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    
    @IBOutlet weak var photoMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollection: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        photoMapView.delegate = self
        
        setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultController()
        collectionView.reloadData()
        getPhotos()
    }
    
    fileprivate func setupMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate.longitude = pin.longitude
        annotation.coordinate.latitude = pin.latitude
        photoMapView.addAnnotation(annotation)
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        // indicates desired zoom level of the map
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        photoMapView.setRegion(region, animated: true)
    }
    
    func getPhotos(){
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            FlickrClient.getPhotos(latitude: pin.latitude, longitude: pin.longitude) { [self] response, error in
                
                if error == nil && response?.photos.photo != nil && response?.photos.total != 0 {
                    guard let response = response
                    else {return}
                    for image in response.photos.photo {
                        let photo = Photos(context: self.dataController.viewContext)
                        photo.creationDate = Date()
                        photo.imageURL = "https://live.staticflickr.com/\(image.server)/\(image.id)_\(image.secret).jpg"
                        photo.pin = self.pin
                        
                        do {
                            try self.dataController.viewContext.save()
                        } catch {
                            fatalError("Unable to save photos: \(error.localizedDescription)")
                        }
                        
                        self.collectionView.reloadData()
                    }
                    print("album saved")
                    self.collectionView.reloadData()
                    
                } else {
                    print("No photo downloaded")
                }
            }
        } else {
            return
        }
    }
    
    // fetched result controller
    func setUpFetchedResultController(){
        
        let fetchRequest : NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format : "pin == %@", argumentArray: [self.pin!])
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch  {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    // collection button action
    @IBAction func collectionButtonTapped(_ sender: Any) {
        
        if let photoAlbum = fetchedResultsController.fetchedObjects{
            for photo in photoAlbum{
                dataController.viewContext.delete(photo)
                setUpFetchedResultController()
                getPhotos()
            }
        }
    }
    
    // collections delegates and data source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        setUpFetchedResultController()
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        DispatchQueue.main.async {
            if let url = photo.imageURL {
                if let image = photo.image {
                    FlickrClient.downloadPhotos(imageURL: URL(string: url)!) { data, error in
                        
                            try? self.dataController.viewContext.save()
                        cell.imageCell.image = UIImage(data: image)
                            print("photo visible")
                    }
                }
            }
            else {
                print("no data")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objectSelected = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(objectSelected)
        
        if var photos = fetchedResultsController.fetchedObjects{
            photos.remove(at: indexPath.row)
        }
        
        try? dataController.viewContext.save()
        setUpFetchedResultController()
    }
    
    
}

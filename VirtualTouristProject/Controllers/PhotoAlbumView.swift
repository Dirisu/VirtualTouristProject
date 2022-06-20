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

class PhotoAlbumViewController: UIViewController,  MKMapViewDelegate, NSFetchedResultsControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource {
    
//    var photo: [NSData] = []
    
    var pin : Pins!
    var photo: Photos!
    var dataController : DataController!
    var fetchedResultController : NSFetchedResultsController<Photos>!
    
    @IBOutlet weak var photoMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollection: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        photoMapView.delegate = self
        
        setupMap()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultController()
        getPhotos()
    }
    
    fileprivate func setupMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate.longitude = pin.longitude
        annotation.coordinate.latitude = pin.latitude
        photoMapView.addAnnotation(annotation)
        
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        photoMapView.setRegion(region, animated: true)
    }
    
    func getPhotos(){
        if fetchedResultController.fetchedObjects?.count == 0 {
            FlickrClient.getPhotos(latitude: pin.latitude, longitude: pin.longitude) { response, error in
                if error == nil && response?.photos.photo != nil {
                    guard let response = response else {return}
                    for image in response.photos.photo{
                        self.photo.imageURL = "https://live.staticflickr.com/\(image.server)/\(image.id)_\(image.secret).jpg"
                        self.photo.pin = self.pin
                        do {
                            try self.dataController.viewContext.save()
                        } catch  {
                            fatalError("Unable to save photos\(error.localizedDescription)")
                        }
                        self.collectionView.reloadData()
                    }
                    print("album saved")
 
                } else {
                    print("No photo downloaded")
                    
                }
            }
        }else{
            return
        }
}
        
    
    
    func setUpFetchedResultController(){
        let fetchRequest : NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format : "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
            
        } catch  {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func collectionButtonTapped(_ sender: Any) {
        
        if let album = fetchedResultController.fetchedObjects{
            for photo in album{
                dataController.viewContext.delete(photo)
                setUpFetchedResultController()
                getPhotos()
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        setUpFetchedResultController()
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        let Photo = fetchedResultController.object(at : indexPath)
        
        
        if let url = Photo.imageURL{
            if let image = Photo.image{
                cell.imageCell.image = UIImage(data: image)
            } else {
                FlickrClient.downloadPhotos(imageUrl: URL(string: url)!) { data, error in
                    if let data = data{
                        let image = UIImage(data: data)
                        cell.imageCell.image = image
                        
                        do {
                            Photo.image = data
                            try self.dataController.viewContext.save()
                        } catch {
                            fatalError("Unable to save photos: \(error.localizedDescription)")
                        }
                        
                    } else {
                        fatalError("error:\(error?.localizedDescription)")
                        
                    }
                }
            }
            
        } else{
            
            print("no photo data")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objectSelected = fetchedResultController.object(at: indexPath)
        dataController.viewContext.delete(objectSelected)
        
        if var photos = fetchedResultController.fetchedObjects{
            photos.remove(at: indexPath.row)
        }
        
        try? dataController.viewContext.save()
        setUpFetchedResultController()
    }
    
}

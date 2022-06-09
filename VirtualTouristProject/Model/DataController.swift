//
//  DataController.swift
//  VirtualTouristProject
//
//  Created by Marvellous Dirisu on 09/06/2022.
//

import Foundation
import CoreData

class DataController {
    // create persistent container
    let persistentContainer: NSPersistentContainer
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // add convinience property to access context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // load persistent store
    func load(completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores {storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}

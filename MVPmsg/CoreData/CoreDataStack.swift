import Foundation
import CoreData

class CoreDataStack {
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let container = self.persistentContainer
        return container.viewContext
    }()
    //MARK: не работает
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return moc
    }()
    //MARK: moc
    private(set) lazy var defManagedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.parent = self.privateManagedObjectContext
        
        return moc
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MVPmsg")
        container.loadPersistentStores() { storeDescr, error in
            if let error = error as NSError? {
                fatalError("\(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private(set) lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        let endIndex = urls.index(before: urls.endIndex)
        return urls[endIndex]
    }()
    
    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
        let modelUrl = Bundle.main.url(forResource: "MVPmsg", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelUrl)!
    }()
    
    private(set) lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("MVPmsg.sqlite")
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: url)
        } catch {
            print(error)
            abort()
        }
        
        return coordinator
    }()
    
}

extension NSManagedObjectContext {
    func saveChanges() {
        do {
            try self.save()
        } catch {
            print(error)
        }
    }
}

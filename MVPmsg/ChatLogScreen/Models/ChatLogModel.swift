//
//  ChatLogModel.swift
//  MVPmsg
//
//  Created by Mihail on 13/08/2019.
//  Copyright © 2019 Mihail. All rights reserved.
//
import CoreData
import Foundation

class ChatLogModel {
    
    var managedObjectContext: NSManagedObjectContext!
    var friend: Friend
    
    init(managedObjectContext: NSManagedObjectContext, friend: Friend) {
        self.managedObjectContext = managedObjectContext
        self.friend = friend
    }
    
    var fetchedResultsController: NSFetchedResultsController<Message> {
        
        let fetchReq = NSFetchRequest<Message>(entityName: "Message")
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchReq.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
        print(friend.name!)
        let frc = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        print(frc.sections?.first)
        return frc
    }
    
}

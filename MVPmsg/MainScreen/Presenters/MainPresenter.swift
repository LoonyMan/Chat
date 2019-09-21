import CoreData
import Foundation

class MainTablePresenter {
    
    var images = ["none", "img1", "img2"]
    var messages: [Message]?
    
    let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.messages = takeMessages()
    }
    
    func createUserWithMessages() {
        let usr = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: managedObjectContext) as! Friend
        
        let randomInt = Int.random(in: 1...10)
        usr.name = "Simulate " + String(randomInt)
        usr.profileImageName = images[Int.random(in: 0...2)]
        
        for _ in 0...randomInt {
            _ = createMessageFromUser(text: "Hello! How do u do?", friend: usr)
            _ = createMessageFromUser(text: "I'm fine, thanks. Can i help u?", friend: usr, isSender: true)
            _ = createMessageFromUser(text: "No ;)", friend: usr)
        }
        managedObjectContext.saveChanges()
    }
    
    func takeMessages() -> [Message]? {
        let friends = fetchFriends()
        guard friends != nil else {return nil}
        let names = deleteDuplicateNames(array: friends!)
        var messagesIn: [Message] = []
        
        for name in names {
            
            let fetchRequest = NSFetchRequest<Message>(entityName: "Message")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "friend.name = %@", name)
            fetchRequest.fetchLimit = 1
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let fetchedMsg = try managedObjectContext.fetch(fetchRequest) as [Message]
                
                messagesIn.append(contentsOf: fetchedMsg)
                
            } catch {
                print(error)
            }
            
        }
        messagesIn = messagesIn.sorted(by: {$0.date?.compare($1.date! as Date) == .orderedDescending})
        return messagesIn
    }
    
    func deleteFriendMessages(friend: Friend) {
        let myQueue = DispatchQueue.init(label: "1")
        myQueue.sync {
            managedObjectContext.delete(friend)
            managedObjectContext.saveChanges()
        }
    }
    
    func getFormattedDate(date: Date) -> String {
        
        let dateForm = DateFormatter()
        dateForm.dateFormat = "HH:mm"
        
        let timeInSeconds = Date().timeIntervalSince(date)
        
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if timeInSeconds > 7 * secondInDays {
            dateForm.dateFormat = "dd/MM/yy"
        } else if timeInSeconds > secondInDays {
            dateForm.dateFormat = "EEE"
        }
        
        return dateForm.string(from: date as Date)
        
    }
    
    // MARK: - Private Function
    
    private func createMessageFromUser(text: String, friend: Friend, date: Date = Date(), isSender: Bool = false) -> Message {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: managedObjectContext) as! Message
        message.friend = friend
        message.text = text
        message.date = Date()
        message.isSender = isSender
        
        return message
    }
    
    private func fetchFriends() -> [Friend]? {
        let req = NSFetchRequest<Friend>(entityName: "Friend")
        
        do {
            return try managedObjectContext.fetch(req) as [Friend]
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func deleteDuplicateNames(array: [Friend]) -> [String] {
        var names = [String]()
        for element in array {
            names.append(element.name!)
        }
        return Array(Set(names))
    }
    
}

//
//  ChatLogPresenter.swift
//  MVPmsg
//
//  Created by Mihail on 13/08/2019.
//  Copyright © 2019 Mihail. All rights reserved.
//
import UIKit
import Foundation
import CoreData


class ChatLogPresenter {
    
    var managedObjectContext: NSManagedObjectContext!
    var frameCollectionView: CGRect!
    var frameSubView: CGRect!
    //var messages: [Message]?
    var friend: Friend!
    
    init(friend: Friend, managedObjectContext: NSManagedObjectContext) {
        self.friend = friend
        self.managedObjectContext = managedObjectContext
    }
    
    func configureCell(cell: ChatLogViewCell, indexPath: IndexPath, view: UIView, fetchedResultController: NSFetchedResultsController<Message>? = nil) -> ChatLogViewCell {
        
        let message = fetchedResultController?.object(at: indexPath) as! Message
        
        cell.bubbleView.layer.cornerRadius = 15
        cell.bubbleView.layer.masksToBounds = true
        
        cell.messageTextField.text = message.text
        
        cell.bubbleView.backgroundColor = UIColor(white: 0.90, alpha: 1)
        
        if let messageText = message.text, let profileImageName = message.friend?.profileImageName {
            
            cell.profileImageName.image = UIImage(named: profileImageName)
            cell.profileImageName.contentMode = .scaleAspectFill
            cell.profileImageName.layer.cornerRadius = 15
            cell.profileImageName.layer.masksToBounds = true
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let customFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
            
            
            if !message.isSender {
                
                cell.messageTextField.frame = CGRect(x: 40 + 8, y: 0, width: customFrame.width + 16, height: customFrame.height + 20)
                cell.bubbleView.frame = CGRect(x: 40, y: 0, width: customFrame.width + 16 + 16, height: customFrame.height + 20)
                cell.profileImageName.frame = CGRect(x: 1, y: 1, width: 32, height: 32)
                cell.profileImageName.isHidden = false
                cell.messageTextField.textColor = .black
                
            } else {
                
                cell.messageTextField.frame = CGRect(x: view.frame.width - customFrame.width - 30, y: 0, width: customFrame.width + 16, height: customFrame.height + 20)
                cell.bubbleView.frame = CGRect(x: view.frame.width - customFrame.width - 38, y: 0, width: customFrame.width + 8 + 16, height: customFrame.height + 20)
                cell.profileImageName.isHidden = true
                cell.bubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 250/255, alpha: 0.7)
                cell.messageTextField.textColor = .white
                
                
            }
            
        }
        return cell
    }
    
    func getSize(indexPath: IndexPath, view: UIView, fetchedResultController: NSFetchedResultsController<Message>? = nil) -> CGSize {
        //2 раза лезет в БД
        let message = fetchedResultController!.object(at: indexPath) as! Message
        if let messageText = message.text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let customFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes:
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
            
            
            return CGSize(width: view.frame.width, height: customFrame.height + 20)
        }
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func sendMessage(text: String, collectionView: UICollectionView) {
        _ = createMessageFromUser(text: text, friend: friend!, isSender: true)
        
        managedObjectContext.saveChanges()

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
    
}

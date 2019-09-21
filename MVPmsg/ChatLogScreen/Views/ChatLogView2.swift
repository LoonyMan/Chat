//
//  ChatLogView.swift
//  MVPmsg
//
//  Created by Mihail on 13/08/2019.
//  Copyright © 2019 Mihail. All rights reserved.
//

//Баг при отправке сообщения,

import CoreData
import UIKit

class ChatLogView2: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var bgMessageView: UIView!
    
    @IBAction func sendButton(_ sender: Any) {
        
        if messageView.text != "" && messageView.textColor != UIColor.lightGray {
            presenter.sendMessage(text: messageView.text, collectionView: collectionView)
            messageView.text = nil
            
        }
        
    }
    
    
    
    var model: ChatLogModel!
    var managedObjectContext: NSManagedObjectContext!
    var friend: Friend! {
        didSet {
            
            presenter = ChatLogPresenter(friend: friend, managedObjectContext: managedObjectContext)
            frc = {
                let fetchRequest = NSFetchRequest<Message>(entityName: "Message")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
                fetchRequest.predicate = NSPredicate(format: "friend.name = %@", self.friend.name!)
                let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                frc.delegate = self
               return frc
            }()
            navigationItem.title = friend?.name
            
        }
    }
    
    var frc: NSFetchedResultsController<Message>!
    
    var presenter: ChatLogPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = ChatLogModel(managedObjectContext: managedObjectContext, friend: self.friend)
        
        do {
            try frc.performFetch()
            
        } catch {
            print(error)
        }
        
        setupDelegate()
        setupPlaceholder()
        
        registerForKeyboardNotifications()
        
        presenter.frameCollectionView = collectionView.frame
        presenter.frameSubView = subView.frame
        
        messageView.layer.cornerRadius = 10
        messageView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 250/255, alpha: 0.9)
        
        setupPlaceholder()
        
        let indexPath = IndexPath(item: (frc.sections?[0].numberOfObjects)! - 1, section: 0)
        
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    func setupNormalStyle() {

        messageView.textColor = UIColor.white
    }
    
    func setupPlaceholder() {
        messageView.text = "Enter message..."
        messageView.textColor = .lightGray
    }
    
    func setupDelegate() {
        messageView.delegate = self
        
        scrollView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func kbWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let kbFrameSize = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
    }
    
    @objc func kbWillHide() {
        scrollView.contentOffset = CGPoint.zero
    }

}



extension ChatLogView2: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            collectionView.insertItems(at: [newIndexPath!])
            collectionView.scrollToItem(at: newIndexPath!, at: .bottom, animated: true)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if let count = presenter.messages?.count {
        if let count = frc.sections?[0].numberOfObjects {
            //print("COUNT = \(count)")
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "msg", for: indexPath) as! ChatLogViewCell
        
        
        return presenter.configureCell(cell: cell, indexPath: indexPath, view: view, fetchedResultController: frc)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if messageView.text == "" {
            setupPlaceholder()
        }
        
        messageView.endEditing(true)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return presenter.getSize(indexPath: indexPath, view: view, fetchedResultController: frc)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
}

extension ChatLogView2: UIScrollViewDelegate {
    
}

extension ChatLogView2: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            setupNormalStyle()
        }
    }
}

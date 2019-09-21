//
//  ChatLogView.swift
//  MVPmsg
//
//  Created by Mihail on 13/08/2019.
//  Copyright © 2019 Mihail. All rights reserved.
//
import CoreData
import UIKit

class ChatLogView: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var subView: UIView!
    
    @IBAction func sendButton(_ sender: Any) {
        presenter.sendMessage(text: messageView.text, collectionView: collectionView)
        messageView.text = nil
        let indexPath = IndexPath(item: presenter.messages!.count - 1, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    var managedObjectContext: NSManagedObjectContext!
    var friend: Friend! {
        didSet {
            
            presenter = ChatLogPresenter(friend: friend, managedObjectContext: managedObjectContext)
            navigationItem.title = friend?.name
            let messages = friend.message?.allObjects as? [Message]
            presenter.messages = messages?.sorted(by: {$0.date?.compare($1.date! as Date) == .orderedAscending})
        }
    }
    
    var presenter: ChatLogPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageView.isScrollEnabled = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        presenter.frameCollectionView = collectionView.frame
        presenter.frameSubView = subView.frame
        
        let indexPath = IndexPath(item: presenter.messages!.count - 1, section: 0)
        
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification, view: UIView) {
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            subView.frame = CGRect(x: 0, y: 2 * subView.frame.height + keyboardFrame.height - 5, width: 375, height: 52)
            let indexPath = IndexPath(item: presenter.messages!.count - 1, section: 0)
            collectionView.frame = CGRect(x: 0, y: 20, width: 375, height: 2 * subView.frame.height + keyboardFrame.height - 25)
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            
        }
    }
}



extension ChatLogView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = presenter.messages?.count {
            
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "msg", for: indexPath) as! ChatLogViewCell
        
        return presenter.configureCell(cell: cell, indexPath: indexPath, view: view)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        messageView.endEditing(true)
        self.subView.frame = presenter.frameSubView
        self.collectionView.frame = presenter.frameCollectionView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return presenter.getSize(indexPath: indexPath, view: view)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

}

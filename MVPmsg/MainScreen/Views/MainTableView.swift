//
//  MainTableView.swift
//  MVPmsg
//
//  Created by Mihail on 13/08/2019.
//  Copyright © 2019 Mihail. All rights reserved.
//

import UIKit

class MainTableView: UITableViewController {
    
    private var presenter = MainTablePresenter(managedObjectContext: CoreDataStack().managedObjectContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func checkData(_ sender: Any) {
        print(presenter.messages)
        
    }
    
    @IBAction func addUser(_ sender: Any) {
        presenter.createUserWithMessages()
        
        reloadData()
    }
    
    // MARK: - Table view data source

    func reloadData() {
        presenter = MainTablePresenter(managedObjectContext: CoreDataStack().managedObjectContext)
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if let count = presenter.messages?.count {
            return count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainTableViewCell
        
        let message = presenter.messages![indexPath.item]
        
        cell.dateLabel.text = presenter.getFormattedDate(date: message.date!)
        cell.messageLabel.text = message.text
        cell.nameLabel.text = message.friend?.name
        cell.profileImage.image = UIImage(named: message.friend?.profileImageName ?? "none")
        cell.miniProfileImage.image = UIImage(named: message.friend?.profileImageName ?? "none")
        
        cell.profileImage.layer.cornerRadius = 15
        cell.miniProfileImage.layer.cornerRadius = 10
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        presenter.deleteFriendMessages(friend: presenter.messages![indexPath.item].friend!)
        
        reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let VC = story.instantiateViewController(withIdentifier: "ChatLogView2") as! ChatLogView2
        
        VC.managedObjectContext = presenter.managedObjectContext
        VC.friend = presenter.messages?[indexPath.row].friend
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
}


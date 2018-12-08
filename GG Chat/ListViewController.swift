//
//  ListViewController.swift
//  GG Chat
//
//  Created by Abel Xu on 10/25/18.
//  Copyright © 2018 Abel Xu. All rights reserved.
//



import UIKit
import Firebase
import ChameleonFramework

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // define a string to store the userId which you want to pass to ChatViewController
    var temp: String?
    
    // define a userArray to store the uerId information retrieved from Firebase
    var userArray : [User] = [User]()
    
    @IBOutlet var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "098cc4")
        
        // hide navigatioin button(< welcome)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        listTableView.delegate = self
        listTableView.dataSource = self
        
        listTableView.register(UINib(nibName: "ListCell", bundle: nil) , forCellReuseIdentifier: "listCell")
        
        configureTableView()

        retrieveUsers()
        
        //listTableView.separatorStyle = .none
    }
    

    
    
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListCell
            cell.userId.text = userArray[indexPath.row].userId
        
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(userArray[indexPath.row].userId)")
        
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                cell.avatar.image = image
            }
        }
        
        
        cell.blockButtonAction = {sender in

            
            let ref = Database.database().reference()
            
            var aaa = true

            ref.child("blockList").observeSingleEvent(of: .value, with: { (snapshot) in
                //let key = snapshot.key
                //let keyString = String(key)
               
                for child in snapshot.children {
                    let snapshotValue = child as! DataSnapshot
                    let value = snapshotValue.value as! Dictionary<String, String>
                    
                 
                    if value["block"] == Auth.auth().currentUser?.email && value["blocked"] == cell.userId.text {
                        aaa = false
                    }
                
                }
                
                if aaa == false {
                     //print("You have blocked this user already")
                    let alertA = UIAlertController(title: "You have blocked this user already.", message: nil, preferredStyle: .alert)
                    alertA.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertA, animated: true)
                }
                else {
                    let blockDictionary = ["block": Auth.auth().currentUser?.email, "blocked": cell.userId.text]
                    ref.child("blockList").childByAutoId().setValue(blockDictionary) {
                        (error, reference) in
                        
                        if error != nil {
                            print(error!)
                        }
                        else {
                            //print("Block list saved successfully!")
                        }
                        
                    }
                    //print("block添加成功")
                    let alertB = UIAlertController(title: "Block successfully!", message: nil, preferredStyle: .alert)
                    alertB.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertB, animated: true)
                }
                
                })
                


            } // end of sender in



        cell.unblockButtonAction = {sender in

            let ref = Database.database().reference()

            var bbb = true
            
            ref.child("blockList").observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                
                for child in snapshot.children {
                    let snapshotValue = child as! DataSnapshot
                    let key = snapshotValue.key
                    let keyString = String(key)
                    
                    // print("key is \(keyString)")
                    
                    let value = snapshotValue.value as! Dictionary<String, String>
                    
                    if value["block"] == Auth.auth().currentUser?.email && value["blocked"] == cell.userId.text {
                        ref.child("blockList").child(keyString).removeValue()
                        
                        let alertC = UIAlertController(title: "Unblock successfully!.", message: nil, preferredStyle: .alert)
                        alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertC, animated: true)
                        
                        bbb = false
                    }
                    
                
                }
                if bbb == true {
                    // print("You did't block this person!")
                    let alertD = UIAlertController(title: "You have not blocked this user. No need to unblock.", message: nil, preferredStyle: .alert)
                    alertD.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertD, animated: true)
                }
                
                
            })
                //let snapshotValue = snapshot.value as? NSDictionary
                //let key = snapshot.key

                //let keyString = String(key)

                
                
//                if a1 == Auth.auth().currentUser?.email && a2 == cell.userId.text {
//                    ref.child("blockList").child(keyString).removeValue()
//
//                }
//
//                else {
//                    print("You have not blockd this user, you don't need to unblock")
//
//
//                }

                //self.configureTableView()
                // self.listTableView.reloadData()

           
                
            

        } // end of sender in


        cell.chatButtonAction = { sender in
            let ref = Database.database().reference()
            
            var ccc = 1
            var ddd = 1
            
            ref.child("blockList").observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                
                for child in snapshot.children {
                    let snapshotValue = child as! DataSnapshot
                    //let key = snapshotValue.key
                    //let keyString = String(key)
                    
                    // print("key is \(keyString)")
                    
                    let value = snapshotValue.value as! Dictionary<String, String>
                    
                    if value["block"] == Auth.auth().currentUser?.email && value["blocked"] == cell.userId.text {
                        
                        ccc = 0
                    }
                    else if value["blocked"] == Auth.auth().currentUser?.email && value["block"] == cell.userId.text {
                        ddd = 0
                    }
                    
                }
                
                
                if ccc == 0 {
                   // print("You can't chat with this user because you have blocked him/her")
                    let alertE = UIAlertController(title: "You have blocked him/her.", message: nil, preferredStyle: .alert)
                    alertE.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertE, animated: true)
                }
                
                if ddd == 0 {
                    // print("You can't chat with this user because you have been blocked by him/her")
                    let alertF = UIAlertController(title: "You have been blocked by him/her.", message: nil, preferredStyle: .alert)
                    alertF.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertF, animated: true)
                }
                
                if ccc != 0 && ddd != 0 {
                    self.temp = cell.userId.text
        
                    if Auth.auth().currentUser?.email == cell.userId.text {
                        let alert = UIAlertController(title: "You can't chat with yourself.", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
        
                    self.performSegue(withIdentifier: "goToChat", sender: self)
                }
                
                
            })


        } // end of sender in
        
        
        
        
        
        
        
//        cell.chatButtonAction = { sender in
//
//            self.temp = cell.userId.text
//
//            if Auth.auth().currentUser?.email == cell.userId.text {
//                let alert = UIAlertController(title: "You can't chat with yourself.", message: nil, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alert, animated: true)
//            }
//
//            self.performSegue(withIdentifier: "goToChat", sender: self)
//
//
//        }
        
        
        
            return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    // MARK: set the number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    
    
    // MARK: set the height of cells
    func configureTableView() {
        listTableView.rowHeight = 100.0
        //listTableView.rowHeight = UITableViewAutomaticDimension
        //listTableView.estimatedRowHeight = 120.0
    }
         
    
    
    // MARK: retrieve userId of each user from Firebase
    func retrieveUsers() {
        let userDB = Database.database().reference().child("UserIds")
        
        userDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let userId = snapshotValue["userId"]!
            
            let user = User()
            user.userId = userId
            
            self.userArray.append(user)
            
            self.configureTableView()
            self.listTableView.reloadData()
        }
    }
    
    
    
    // MARK: pass the value of userId of whom you want to chat with to the next viewcontroller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ChatViewController = segue.destination as? ChatViewController {
            ChatViewController.userToChat = temp
        }
    }
    
    
    
    // MARK: logout
    func logOut(action: UIAlertAction) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("error: there was a problem logging out")
        }
    }
    
    
    
    // MARK: action of pressing logout button
    @IBAction func logOutPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure to log out?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: logOut))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    
    

}




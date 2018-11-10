//
//  WelcomeViewController.swift
//  GG Chat
//
//  This is the welcome view controller - the first thign the user sees
//

import UIKit
import Firebase
import UserNotifications


class WelcomeViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "aec0da")
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "goToList", sender: self)
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

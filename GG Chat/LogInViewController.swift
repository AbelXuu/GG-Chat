//
//  LogInViewController.swift
//  GG Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    
    // MARK: action of preesing login button
    @IBAction func logInPressed(_ sender: AnyObject) {
        if emailTextfield.text == "" || passwordTextfield.text == ""
            {
                let loginAlert = UIAlertController(title: "Login error!", message: "Please fill all the fields.", preferredStyle: .alert)
                loginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(loginAlert, animated: true)
            }
        else
            {
                Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
                    if error != nil
                        {
                            print(error!)
                            
                            let alert = UIAlertController(title: "Wrong email or password!", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    else
                        {
                            SVProgressHUD.show()
                            print("Log in successful!")
                            
                            SVProgressHUD.dismiss()
                            
                            self.performSegue(withIdentifier: "goToList", sender: self)
                        }
                }
            }
    }
    
}  

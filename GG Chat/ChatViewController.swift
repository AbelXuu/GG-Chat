//
//  ViewController.swift
//  GG Chat
//
//

import UIKit
import Firebase
import ChameleonFramework
import UserNotifications
import NotificationCenter



class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UNUserNotificationCenterDelegate, UIGestureRecognizerDelegate{
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    
    var avatar1: UIImage?
    var avatar2: UIImage?
    
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    var topButton = UIButton()
    
    // get the value of userId passed from the ListViewController
    var userToChat: String? = nil
    
    // get the model of user's iPhone
    let modelName = UIDevice.modelName
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        tableViewScrollToBottom()
        
        // observer of keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboradWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        messageTableView.register(UINib(nibName: "MessageCell2", bundle: nil) , forCellReuseIdentifier: "customMessageCell2")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(tableViewSwipedDown(gesture:)))
        swipeDownGesture.delegate = self // 很重要！！！ 否则只能检测左右滑动而不能检测上下滑动
        swipeDownGesture.direction = .down
        messageTableView.addGestureRecognizer(swipeDownGesture)
        
        messageTextfield.delegate = self
        
        
        retrieveMessages()
        retrieveProfilePhoto()
        
        configureTableView()
        
        
        //scroll to last cell
        
        messageTableView.separatorStyle = .none
    }
    
    
    
    //MARK: 很重要！！！ 否则只能检测左右滑动而不能检测上下滑动
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    //MARK: action of swiping the tableview down
    @objc func tableViewSwipedDown(gesture:UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            if gesture.direction == .down {
                // Perform action.
                
                keyboardDown()
                textFieldDown()
            }
        }
        
    }
    
    
    
    
    //MARK: 当键盘打开时的事件
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        
        UIView.animate(withDuration: 0.2) {
            self.tableViewScrollToBottom()
            
            if self.modelName == "iPhone X" || self.modelName == "iPhone XS"{
                
                self.heightConstraint.constant = keyboardHeight + 18
            }
            else if self.modelName == "iPhone X Max" {
                self.heightConstraint.constant = keyboardHeight + 23
            }
            else if self.modelName == "iPhone XR" {
                
                self.heightConstraint.constant = keyboardHeight + 20
            }
            else if self.modelName == "iPhone 6" || self.modelName == "iPhone 6s" || self.modelName == "iPhone 7" || self.modelName == "iPhone 8"{
                self.heightConstraint.constant = keyboardHeight + 55
            }
            else if self.modelName == "iPhone 6 Plus" || self.modelName == "iPhone 6s Plus" || self.modelName == "iPhone 7 Plus" || self.modelName == "iPhone 8 Plus"{
                self.heightConstraint.constant = keyboardHeight + 55
            }
            else {
                self.heightConstraint.constant = keyboardHeight + 45
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: 当键盘关闭时的事件
    @objc func keyboradWillHide(notification: NSNotification) {
        tableViewScrollToBottom()
    }
    
    
    
   
    
    
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell2", for: indexPath) as! CustomMessageCell2
            
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender
            cell.messageTime.text = messageArray[indexPath.row].messageTime
            cell.avatarImageView.image = avatar1
            
            cell.messageBackground.backgroundColor = UIColor(red:0.12, green:0.69, blue:0.21, alpha:1.0)
           
            
            
            
            cell.deleteButtonAction = { sender in
               
                let ref = Database.database().reference()
                
                ref.child("Messages").observe(.childAdded) { (snapshot) in
                    let snapshotValue = snapshot.value as! Dictionary<String, String>
                    let key = snapshot.key
                    
                    let keyString = String(key)
                   
                    //let timeHere = self.timeChange1(self.messageArray[indexPath.row].messageTime)
                    
                    if snapshotValue["Sender"] == self.messageArray[indexPath.row].sender && snapshotValue["MessageBody"] == self.messageArray[indexPath.row].messageBody && snapshotValue["messageTime"] == self.timeChange1(self.messageArray[indexPath.row].messageTime) {
                        // remove data from database
                        
                        
                            ref.child("Messages").child(keyString).removeValue()
                            
                            // remove data from messageArray(local memory)
                            self.messageArray[indexPath.row].messageBody = "Please leave this chat page and enter again to refresh the data."
                            
                            
                            self.configureTableView()
                            self.messageTableView.reloadData()
                            
                            let alert = UIAlertController(title: "Delete Successfully！", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true)
                      
                    }
                
                }
            
            }
            
            return cell
        }
         
          
            
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
            
            //cell.flagLabel.text = messageArray[indexPath.row].messageFlag
            
            if messageArray[indexPath.row].messageFlag == "show" {
                cell.messageBody.text = messageArray[indexPath.row].messageBody
            } else {
                cell.messageBody.text = "This message is hidden"
            }
            
            
            cell.senderUsername.text = messageArray[indexPath.row].sender
            cell.messageTime.text = messageArray[indexPath.row].messageTime
            cell.avatarImageView.image = avatar2
            
            cell.messageBackground.backgroundColor = UIColor.flatGray()
            
            
            
            cell.flagButtonAction = {sender in
                
                let ref2 = Database.database().reference()
                ref2.child("Messages").observe(.childAdded) { (snapshot) in
                    let snapshotValue = snapshot.value as! Dictionary<String, String>
                    let key = snapshot.key
                    
                     let keyString = String(key)
                    
                    if snapshotValue["Sender"] == self.messageArray[indexPath.row].sender && snapshotValue["MessageBody"] == self.messageArray[indexPath.row].messageBody && snapshotValue["messageTime"] == self.timeChange1(self.messageArray[indexPath.row].messageTime) {
                        
                        if snapshotValue["messageFlag"] == "show" {
                            ref2.child("Messages").child(keyString).updateChildValues(["messageFlag": "hide"])
                            self.messageArray[indexPath.row].messageFlag = "hide"
                            
                            self.configureTableView()
                            self.messageTableView.reloadData()
                       
                        }
                        else {
                            ref2.child("Messages").child(keyString).updateChildValues(["messageFlag": "show"])
                            self.messageArray[indexPath.row].messageFlag = "show"
                            
                            self.configureTableView()
                            self.messageTableView.reloadData()
                      
                        }
                        
                    }
                    
            }
            }
           
            return cell
        }
      
    }
    
    
    
    
    //MARK: set the number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    
    //MARK: action when table view be tapped
    @objc func tableViewTapped() {
        keyboardDown()
        textFieldDown()
    }
    
    
    
    //MARK: set the height of cell
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
        
        
    }
    
    
    
    
    //MARK: move down the textField
    func textFieldDown() {
        UIView.animate(withDuration: 0.2) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
    //MARK: hide the keyboard
    func keyboardDown() {
        
        view.endEditing(true)
    }
    
    
    
    
    //MARK: things to do when pressed send button
    func sendAction() {
        
        if messageTextfield.text == "" {
            let alert = UIAlertController(title: "You can't send a empty message.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            
            
            
            let messagesDB = Database.database().reference().child("Messages")
            
            let messageDictionary = ["userId1": Auth.auth().currentUser?.email!, "userId2": userToChat, "Sender": Auth.auth().currentUser?.email,
                                     "MessageBody": messageTextfield.text!, "messageTime": convertFromDateToString(), "messageFlag": "show"]
            
            messagesDB.childByAutoId().setValue(messageDictionary) {
                (error, reference) in
                if error != nil {
                    print(error!)
                }
                else {
                    
                }
                
                self.messageTextfield.isEnabled = true
                
                self.messageTextfield.text = ""
            }
        }
    }
    
    
    
    
    //MARK: press ruturn button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        sendAction()
        
        return true
    }
    
    
    
    
    
    
    //MARK: retrieve message information from Firebase
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            if (snapshotValue["Sender"] == Auth.auth().currentUser?.email && snapshotValue["userId2"] == self.userToChat) || (snapshotValue["userId2"] == Auth.auth().currentUser?.email && snapshotValue["Sender"] == self.userToChat) {
                let userId1 = snapshotValue["userId1"]!
                let userId2 = snapshotValue["userId2"]!
                let sender = snapshotValue["Sender"]!
                let text = snapshotValue["MessageBody"]!
                let time = snapshotValue["messageTime"]!
                let messageFlag = snapshotValue["messageFlag"]!
                
                let message = Message()
                message.userId1 = userId1
                message.userId2 = userId2
                message.messageBody = text
                message.sender = sender
                message.messageFlag = messageFlag
                
                let timeFitUsersTimezone = self.convertFromStringToDateThenChangeTimezonethanConvertItToString(time)
                
                message.messageTime = timeFitUsersTimezone
                
                self.messageArray.append(message)
                
                
                self.configureTableView()
                self.messageTableView.reloadData()
                self.tableViewScrollToBottom()
            }
        }
        
        
        
    }
    
    
    
    
    
    //MARK: retrieve profilephoto from Firebase storage
    func retrieveProfilePhoto() {
        let currentUser = Auth.auth().currentUser?.email!
        let anotherUser = userToChat
        
        let storageRef = Storage.storage().reference()
        
        let imageRef1 = storageRef.child("images/\(currentUser!)")
        
        
        let imageRef2 = storageRef.child("images/\(anotherUser!)")
        
        
        imageRef1.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image1 = UIImage(data: data!)
                self.avatar1 = image1
                
                
                // 非常重要！！！！否则打开聊天窗口后不会立即显示头像
                self.configureTableView()
                self.messageTableView.reloadData()
            }
        }
        
        imageRef2.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                
                let image2 = UIImage(data: data!)
                self.avatar2 = image2
                
                self.configureTableView()
                self.messageTableView.reloadData()
            }
        }
    }
    
    
    
    
    
    
    
    
    // 将英国标准时间转成string存进database
    func convertFromDateToString () -> String {
        
        let now = Date()
        //print("\(now)")
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM/dd/yyyy  HH:mm     .SSSZ"
        
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let result = dateFormatter.string(from: now)
        
        
        //print("\(result)")
        
        return result
        
    }
    
    // 将database里的应该标准时间准成Date形式，然后转成用户所在时区， 最后转回成string用以在用户屏幕上显示
    func convertFromStringToDateThenChangeTimezonethanConvertItToString (_ time: String) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM/dd/yyyy  HH:mm     .SSSZ"
        
        let temp = dateFormatter.date(from: time)
        
        dateFormatter.timeZone = .current
        
        let result = dateFormatter.string(from: temp!)
        
        //result = String(result.prefix(17))
        //dateFormatter.locale = Locale.init(identifier: "en_GB")
    
        return result
        
    }
    
    
    // 将用户本地的string时间转成Date形式，再转换成英国标准时间，最后将其转成string行驶
    func timeChange1(_ time: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy  HH:mm     .SSSZ"
        let temp = dateFormatter.date(from: time)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let result = dateFormatter.string(from: temp!)
        //print(result)
        return result
        
    }
        
        func timeChange2(_ time: String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy  HH:mm     .SSSZ"
            let temp = dateFormatter.date(from: time)
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            let result = dateFormatter.string(from: temp!)
            //print(result)
            return result
            
        }
    
    
    
    
    
    
    
    //MARK: scroll to the bottom of the UItableView
    func tableViewScrollToBottom(animated: Bool = false) {
        
        if messageArray.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(1000)) {
                self.messageTableView.scrollToRow(at: IndexPath(row: self.messageArray.count - 1, section: 0), at: .bottom, animated: animated)
            }
            
        }
    }
    
}













// get the model of iPhone
public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}


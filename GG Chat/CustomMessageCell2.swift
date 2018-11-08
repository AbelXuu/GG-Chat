//
//  CustomMessageCell2.swift
//  GG Chat
//

import UIKit

class CustomMessageCell2: UITableViewCell {

    var onButtonTapped : (() -> Void)? = nil
    
    
    @IBOutlet var messageBackground: UIView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var senderUsername: UILabel!
    @IBOutlet var messageTime: UILabel!
    @IBOutlet var deleteButton: UIButton!
    
    
    var deleteButtonAction: ((Any) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteButtonClicked(_ sender: Any) {
        self.deleteButtonAction?(sender)
    }
    
    
    
    
    
}

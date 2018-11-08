//
//  CustomMessageCell.swift

import UIKit

class CustomMessageCell: UITableViewCell {

    var onButtonTapped : (() -> Void)? = nil
    
    
    @IBOutlet var messageBackground: UIView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var senderUsername: UILabel!
    @IBOutlet var messageTime: UILabel!
    @IBOutlet var flagButton: UIButton!
    @IBOutlet var flagLabel: UILabel!
    
    
    var flagButtonAction: ((Any) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func flagButtonClicked(_ sender: Any) {
        
        self.flagButtonAction?(sender)
    }
    

   
    
}

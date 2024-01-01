//
//  TestPrototypeCell.swift
//  INR_Tracker_App_Storyboard
//
//  Created by Chris Brunet on 2023-12-23.
//

import UIKit

class TestPrototypeCell: UITableViewCell {
    
    // declaring outlets for labels in each table cell in the Storyboard UI
    @IBOutlet weak var reading: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

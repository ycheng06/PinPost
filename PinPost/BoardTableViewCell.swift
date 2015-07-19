//
//  BoardTableViewCell.swift
//  PinPost
//
//  Created by Jason Cheng on 7/19/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import UIKit

class BoardTableViewCell: UITableViewCell {

    @IBOutlet weak var boardTypeLabel: UILabel!
    @IBOutlet weak var boardImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

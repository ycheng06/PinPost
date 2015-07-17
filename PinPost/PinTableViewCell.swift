//
//  PinTableViewCell.swift
//  PinPost
//
//  Created by Jason Cheng on 7/17/15.
//  Copyright (c) 2015 Jason. All rights reserved.
//

import UIKit

class PinTableViewCell: UITableViewCell {


    @IBOutlet weak var boardTypeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

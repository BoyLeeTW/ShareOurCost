//
//  PendingExpenseListTableViewCell.swift
//  ShareOurCost
//
//  Created by Brad on 02/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit

class PendingExpenseListTableViewCell: UITableViewCell {
    @IBOutlet weak var pendingExpenseNameLabel: UILabel!
    @IBOutlet weak var acceptExpenseButton: UIButton!
    @IBOutlet weak var denyExpenseButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

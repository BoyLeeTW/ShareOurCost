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
    @IBAction func touchAcceptPendingExpense(_ sender: Any) {

        

    }

    @IBAction func touchDenyPendingExpense(_ sender: Any) {

    

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

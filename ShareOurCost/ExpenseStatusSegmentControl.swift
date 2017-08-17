//
//  ExpenseStatusSegmentControl.swift
//  ShareOurCost
//
//  Created by Brad on 17/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit

class ExpenseStatusSegmentControl: UISegmentedControl {

    override func awakeFromNib() {
        super.awakeFromNib()

        for selectView in subviews{
            selectView.layer.borderColor = UIColor.clear.cgColor
            selectView.layer.borderWidth = 0
            selectView.layer.cornerRadius = 0
//            selectView.layer.masksToBounds = true
        }
    }
}

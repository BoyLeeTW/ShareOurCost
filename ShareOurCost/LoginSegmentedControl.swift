//
//  LoginSegmentedControl.swift
//  ShareOurCost
//
//  Created by Brad on 23/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit

class LoginSegmentedControl: UISegmentedControl {

    override func awakeFromNib() {
        super.awakeFromNib()

        for selectView in subviews {
            selectView.layer.borderColor = UIColor.clear.cgColor
            selectView.layer.cornerRadius = 0
        }

    }

}

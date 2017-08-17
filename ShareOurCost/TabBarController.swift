//
//  TabBarViewController.swift
//  ShareOurCost
//
//  Created by Brad on 16/08/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)

        self.tabBar.barTintColor = UIColor.white

        self.tabBar.isTranslucent = false

    }

}

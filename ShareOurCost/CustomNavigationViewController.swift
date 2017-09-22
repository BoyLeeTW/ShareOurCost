//
//  CustomNavigationViewController.swift
//  ShareOurCost
//
//  Created by Brad on 21/09/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    enum PresentedOrPushed {

        case presented, pushed

        case `nil`

    }

    func setUpNavigationBar(withTitle title: String, presentedOrPushed: PresentedOrPushed) {

        switch presentedOrPushed {

        case .presented:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_white"), style: .plain,
                                                                    target: self,
                                                                    action: #selector(touchBackButtonToDismiss))

        case .pushed:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_navigate_before_white_36pt"), style: .plain,
                                                                    target: self,
                                                                    action: #selector(touchBackButtonToPop))

        case .nil: break

        }

        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        self.navigationController?.navigationBar.topItem?.title = "\(title)"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 155/255, blue: 180/255, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.layer.borderColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 18.0)!]

    }

    func touchBackButtonToDismiss() {
        
        self.dismiss(animated: true, completion: nil)
        
    }

    func touchBackButtonToPop() {
        
        self.navigationController?.popViewController(animated: true)
        
    }

}

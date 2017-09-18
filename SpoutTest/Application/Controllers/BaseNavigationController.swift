//
//  BaseNavigationController.swift
//  SpoutTest
//
//  Created by Asquare on 9/19/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
        navigationBar.barTintColor = .black
        let textAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationBar.titleTextAttributes = textAttributes
    }


}

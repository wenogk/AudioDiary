//
//  TabBarController.swift
//  AudioDiary
//
//  Created by Romeno Wenogk Fernando on 28/07/2020.
//  Copyright © 2020 Romeno Wenogk Fernando. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

        @IBInspectable var defaultIndex: Int = 0

        override func viewDidLoad() {
            super.viewDidLoad()
            selectedIndex = defaultIndex
        }

    }

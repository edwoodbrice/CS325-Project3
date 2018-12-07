//
//  NavigationBarAttachedViewController.swift
//  QuickBin
//
//  Created by User on 12/7/18.
//  Copyright © 2018 cs325-project3. All rights reserved.
//

import UIKit

class NavigationBarAttachedViewController: UIViewController, UIBarPositioningDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

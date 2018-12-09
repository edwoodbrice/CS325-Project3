//
//  SpinLoadingButton.swift
//  QuickBin
//
//  Created by User on 12/9/18.
//  Copyright © 2018 cs325-project3. All rights reserved.
//

import UIKit

class SpinLoadingButton: UIButton {
    private var indicator: UIActivityIndicatorView?
    var showsActivityIndicator: Bool {
        get {
            return self.indicator != nil
        }
        set {
            if newValue {
                // TODO: set up.
            }
            else {
                // TODO: remove.
            }
        }
    }
    
}

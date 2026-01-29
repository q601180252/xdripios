/*
 * Copyright © 2021, Semiconductor Components Industries, LLC
 * (d/b/a ON Semiconductor). All rights reserved.
 *
 * This code is the property of ON Semiconductor and may not be redistributed
 * in any form without prior written permission from ON Semiconductor.
 * The terms of use and warranty for this code are covered by contractual
 * agreements between ON Semiconductor and the licensee.
 *
 * This is Reusable Code.
 *
 * Class Name: UIBarButtonItem+Extensions.swift
*/

import Foundation
import UIKit

enum BarButtonItemType:Int {
    case backButton
    case backDisabledButton
}

extension UIBarButtonItem {
    
    convenience init(withCustomType type: BarButtonItemType, target: Any, action: Selector) {
        var imageName: String = ""
        var buttonTitle: String = "Back"
        switch type {
        case .backButton:
            imageName = "BackIcon"
            buttonTitle = ""
        case .backDisabledButton:
            imageName = "BackDisabledIcon"
            buttonTitle = ""
        }
        
        let button = UIButton()
        guard let image = UIImage(named: imageName) else {
            self.init(customView:button)
            return
        }
        button.setImage(image, for: .normal)
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.frame = CGRect(x: 0.0, y: 0.0, width: image.size.width + 10.0, height: image.size.height)
        self.init(customView:button)
    }
}

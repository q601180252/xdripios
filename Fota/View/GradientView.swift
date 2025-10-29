/*
* Copyright © 2021, Semiconductor Components Industries, LLC
* (d/b/a ON Semiconductor). All rights reserved.
*
* This code is the property of ON Semiconductor and may not be redistributed
* in any form without prior written permission from ON Semiconductor.
* The terms of use and warranty for this code are covered by contractual
* agreements between ON Semiconductor and the licensee.
*
* This is Reusable Code
*
* Class Name: GradientView.swift
*/

import UIKit

class GradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }

        theLayer.colors = [#colorLiteral(red: 0.7403950095, green: 0.8693494797, blue: 0.915393889, alpha: 1).cgColor, #colorLiteral(red: 0.4515625834, green: 0.9173617959, blue: 0.7845830321, alpha: 1).cgColor]
        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

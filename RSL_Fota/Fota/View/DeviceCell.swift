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
* Class Name: DeviceCell.swift
*/

import UIKit

class DeviceCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var rssiImage: UIImageView!
    @IBOutlet weak var shadedView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.shadedView.layer.cornerRadius = 7.0
        self.containerView.backgroundColor = .white
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.fotaRoundCorners([.bottomRight, .topRight], radius: 7.0)
    }
    
}

extension UIView {
    
    class func fromNib<T: UIView>() -> T? {
        return UINib(nibName: "\(self)", bundle: nil).instantiate(withOwner: nil, options: nil).first as? T
    }
    
    func fotaRoundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: 7.0, height: 7.0)).cgPath
        self.layer.mask = maskLayer
        self.layer.masksToBounds = true
    }
}

extension DeviceCell {
    
    // this is not the view model. Needs to be created with view model
    func configure(withName name: String, withUUID uuid: String, rssiValue: NSNumber) {
        nameLabel.text = name
        uuidLabel.text = uuid
        rssiLabel.text = rssiValue .stringValue + "dBm"
        updateRSSI(rssiValue)
    }
    
    func updateRSSI(_ value: NSNumber) {
        if value .intValue > -50 {
            rssiImage.image = #imageLiteral(resourceName: "ic_rssi_four")
        } else if value .intValue < -50 && value .intValue > -65{
            rssiImage.image = #imageLiteral(resourceName: "ic_rssi_three")
        } else if value .intValue < -65 && value .intValue > -80{
            rssiImage.image = #imageLiteral(resourceName: "ic_rssi_two")
        }else if value .intValue < -80 && value .intValue > -100{
            rssiImage.image = #imageLiteral(resourceName: "ic_rssi_one")
        }else {
            rssiImage.image = #imageLiteral(resourceName: "ic_rssi_zero")
        }
    }
    func updateLayoutsIfNeccessary() {
        self.perform(#selector(layoutSubviews), with: nil, afterDelay: 0.1)
    }
}
    

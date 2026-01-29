//
//  Phy.swift
//  fota
//
//  PHY's that may be used
//
//  Created by Sam Andersson on 14.01.19.
//  Copyright © 2019 Arendi Ag. All rights reserved.
//

import Foundation
public enum Phy: Int
{
    /**
     * 1Mbps this is the default phy at connection establishment
     */
    case oneMbps = 0
    
    /**
     * 2Mbit
     */
    case twoMbps = 1
    
    /**
     * Coded S2
     */
    case codedS2 = 2
    
    /**
     * Coded S8
     */
    case codedS8 = 3

    var description: String
    {
        switch self {
        case .oneMbps:
            return "1Mbps"
        case .twoMbps:
            return "2Mbps"
        case .codedS2:
            return "CodedS2"
        case .codedS8:
            return "CodedS8"
        }
    }
}

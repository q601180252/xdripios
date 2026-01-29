/******************************************************************************
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
 * Class Name: WriteType.swift
 ******************************************************************************/

import Foundation
public enum WriteType
{
    /**
     The implementaion decides what write operation is the best choice. The criterias are: 1) Which write types are supported 2) Reliability is prefered.
     */
    case general
    
    /**
     Use a write command. The write command can be used on characteristics with write without response support. Due to the not required response this is the faster communication, but there is no confirmation till the operation is completed.
     */
    case command
    
    /**
     The write request is the reliable write operation. It is confirmed by the peer device and there is an error feedback if the peer doesn't acknowledge the oepration
     */
    case request    
}

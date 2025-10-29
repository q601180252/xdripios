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
 * Class Name: UpdateProviderProtocol.swift
 ******************************************************************************/

import Foundation
public protocol UpdateProviderProtcol
{
    /**
     * Blocking update methode.
     * @Parameter peripheral: Peripheral that gets updated
     * @Parameter source: Source for the update process. See implementaion process for details
     * @Parameter options: Options for the update progress. Se implementatiion update process for details
     */
    func update(periheral: EnhancedPeripheralProtocol, source: Any, options: Any)throws
}

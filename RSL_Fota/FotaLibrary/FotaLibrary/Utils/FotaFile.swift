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
 * Class Name: FotaFile.swift
 ******************************************************************************/

import Foundation
public struct FotaFile
{
    //MARK: Properties
    /**
     Get the fota file path
     */
    public var filePath: String
    {
        return _filePath
    }
    
    /**
     Get the fota firmware image
     */
    public var fotaImage: FotaFirmwareImage
    {
        return _fotaImage
    }
    
    /**
     Get the app image
     */
    public var AppImage: FotaFirmwareImage
    {
        return _appImage
    }
    
    //MARK: Members
    private var _filePath: String
    private var _fotaImage: FotaFirmwareImage
    private var _appImage: FotaFirmwareImage
    
    //MARK: Initilizer
    /**
     Instantiates an fota file object. The file shall exist inte the device onbox folder
     
     - parameters:
        - fileName: The name of the fota file
     
     - throws:
        - fatalError
     */
    public init(filePath: String)
    {
        _filePath = filePath
        do
        {
            let fileData = try Data(contentsOf: URL(fileURLWithPath: filePath))
            var offset: UInt32 = 0
            
            _fotaImage = FotaFirmwareImage()
            _fotaImage.parse(fileData: fileData, offset: &offset)
            
            _appImage = FotaFirmwareImage()
            _appImage.parse(fileData: fileData, offset: &offset)
            
            print("FotaImage: fota:\(_fotaImage.version)")
            print("FotaImage: app:\(_appImage.version)")
        }
        catch
        {
            fatalError("FotaFile: Error in creating FotaFile: \(error)")
        }
    }    
}

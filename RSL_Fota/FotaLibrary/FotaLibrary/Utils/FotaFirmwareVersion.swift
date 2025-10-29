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
 * Class Name: FotaFirmwareVersion.swift
 ******************************************************************************/

import BleLibrary
import Foundation
import os.log
public struct FotaFirmwareVersion {
    
    //MARK: Members
    private var _imageId: String
    private var _imageVersion: String
    
    //MARK: Properties
    /**
     Get the image id
     */
    public var imageId: String
    {
        return _imageId
    }
    
    /**
     Get the image version
     */
    public var imageVersion: String
    {
        return _imageVersion
    }
    
    /**
     Get the image description
     */
    public var description: String
    {
        return "\(imageId) \(imageVersion)"
    }
    
    public init()
    {
        _imageId = "N/A"
        _imageVersion = "N/A"
    }
    
    /**
     Sets the version from byte array
     
     - parameters:
        - data: The version data from firmware image file
     */
    public mutating func setVersion(data: Data)throws
    {
        do{
            try setVersion(data: data, offset: 0, length: data.count)
        }
        catch let error
        {
            throw error
        }
    }
    
    /**
     Sets the version from byte array
     
     - parameters:
        - data: The version data from firmware image file
        - offset: The offset in the data array
        - length: the length of teh data
     */
    public mutating func setVersion(data: Data, offset: Int, length: Int) throws
    {
        guard length == 8 else{
            throw BleLibraryError.illegalArgument(message: "Expected 8 byte version data but received: \(length)")
        }
        
        if data[offset] == 0x00
        {
            self._imageVersion = "N/A"
            self._imageId = ""
            return
        }
        
        _imageId = String(data: data.subdata(in: offset..<(offset + 6)), encoding: String.Encoding.utf8)!
        do{
            let code: UInt16 = try BufferAccess.ReadUInt16LittleEndian(buffer: [UInt8](data), offset: (offset+6))
            _imageVersion = decodeVersion16Bit(code: code)
        }
        catch
        {
        }
    }
    
    private mutating func decodeVersion16Bit(code: UInt16) -> String
    {
        let version = "\(((code >> 12) & 0xF)).\(((code >> 8) & 0xF)).\(((code >> 0) & 0xFF))"
        return  version
    }
}

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
 * Class Name: FotaFirmwareImage.swift
 ******************************************************************************/

import BleLibrary
import Foundation
import os.log
import CoreBluetooth
public struct FotaFirmwareImage
{
    //MARK: Properties
    
    /**
     Get the fota firmware version
     */
    public var version: FotaFirmwareVersion
    {
        return _version!
    }
    
    /**
     Get the device Id
     */
    public var deviceId: Data
    {
        return _deviceId!
    }
    
    /**
     Get the image data
     */
    public var imageData: Data
    {
        return _imageData!
    }
    
    /**
     Get the build id
     */
    public var buildId: Data
    {
        return _buildId!
    }
    
    /**
     Get the fota service uuid
     */
    public var fotaServiceUuid: CBUUID
    {
        return _fotaServiceUuid!
    }
    
    //MARK: Members
    private var _version: FotaFirmwareVersion? = nil
    private var _deviceId: Data? = nil
    private var _imageData: Data? = nil
    private var _buildId: Data? = nil
    private var _fotaServiceUuid: CBUUID? = nil
    private let log: LogProtocol = LogManager.manager.createLog(name: "FotaFirmwareImage")
    
    private let signatureSize: Int = 64
    
    init(){}
    
    /**
     Prase the file and extract the data from it
     
     - parameters:
        - fileData: The file in format Data
        - offset: UInt32 where to start reade the data
     */
    public mutating func parse(fileData: Data,  offset: inout UInt32)
    {
        let fileOffset: UInt32 = offset
        let isFotaImage: Bool = fileOffset == 0;
        
        do
        {
            var initialStackPointer = try BufferAccess.ReadUInt32LittleEndian(buffer: fileData.toArray(), offset: Int(offset))
            offset += 4
            let resetHandler = try BufferAccess.ReadUInt32LittleEndian(buffer: fileData.toArray(), offset: Int(offset))
            offset += 4
            let checkRSL10OrRSL15 = try BufferAccess.ReadUInt32LittleEndian(buffer: fileData.toArray(), offset: 36)
            if checkRSL10OrRSL15 == 0{
                offset += (4 * 5)
            }else{
                offset += (4 * 6)
            }
            let versionInfoPointer = try BufferAccess.ReadUInt32LittleEndian(buffer: fileData.toArray(), offset: Int(offset))
            offset += 4
            let imageDescriptorPointer = try BufferAccess.ReadUInt32LittleEndian(buffer: fileData.toArray(), offset: Int(offset))
            offset += 4
            
            let imageStartAddress = UInt32(resetHandler & ~0x7ff)
            
            let offsetVersionInfo = versionInfoPointer - imageStartAddress + fileOffset
            let offsetImageDescriptor = imageDescriptorPointer - imageStartAddress + fileOffset
            
            offset = offsetVersionInfo
            try checkBounds(data: fileData, address: offset, size: 8 + 16, info: "Version info offset")
            
            self._version = FotaFirmwareVersion()
            try self._version!.setVersion(data: fileData, offset: Int(offset), length: 8)
            offset += 8
            _deviceId = fileData.subdata(in: (Int(offsetVersionInfo) + 8)...(Int(offsetVersionInfo) + 24))
            offset += 16
            
            if isFotaImage
            {
                // read cnfiguration structure
                var configLength = try BufferAccess.ReadUInt32LittleEndian(buffer: fileData.toArray(), offset: Int(offset))
                offset += 4
                
                //public key
                offset += 64
                
                // service uuid
                let serviceUuidData: Data = fileData.subdata(in: Int(offset)...Int(offset + 16))
                _fotaServiceUuid = CBUUID(data: serviceUuidData.reverse())
                offset += 16
                let nameLenght = try BufferAccess.ReadUInt16LittleEndian(buffer: fileData.toArray(), offset: Int(offset))
                offset += 2
                var name = String(data: fileData.subdata(in: Int(offset)...(Int(offset) + Int(nameLenght))), encoding: String.Encoding.utf8) as String?
            }
            
            offset = offsetImageDescriptor
            try checkBounds(data: fileData, address: offset, size: signatureSize + 4 + 32, info: "Image descriptor offset")
            
            var imageSize = try BufferAccess.ReadUInt32LittleEndian(buffer: fileData.toArray(), offset: Int(offset))
            imageSize += UInt32(signatureSize)
            offset += 4
            _buildId = fileData.subdata(in: Int(offset)...Int(offset + 32))
            
            try checkBounds(data: fileData, address: fileOffset + imageSize, size:0 , info: "Image end")
            _imageData = fileData.subdata(in: Int(fileOffset)...Int(fileOffset + imageSize))
            offset = imageSize
            
            // pad offset to 2048
            offset = offset + 2048 - (offset) % 2048
        }
        catch
        {
            log.error("Error \(error)")
            return
        }
        
    }
    
    private func checkBounds(data: Data, address: UInt32, size: Int, info: String)throws
    {
        if (address + UInt32(size)) > data.count
        {
            throw FotaError.General(message:"\(info) out of range: 0x\(String(format: "%04X", address))", status: FotaStatus.genaralError)
        }
    }
}

extension Data {
    func subdata(in range: ClosedRange<Index>) -> Data{
        return subdata(in: range.lowerBound..<range.upperBound)
    }
    
    mutating func insertRangeAt(source: Data, sourceIndex: Int, destinationIndex: Int, length: Int)
    {
        for i in 0..<length
        {
            self.insert(source[i + sourceIndex], at: (destinationIndex + i))
        }
    }
    
    func reverse() -> Data{
        return Data(reversed())
    }
    
    func toArray() -> [UInt8]{
        return [UInt8](self)
    }
}



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
 * Class Name: BufferAccess.swift
 ******************************************************************************/

import Foundation
public struct BufferAccess
{
    //MARK: Read Little Endian    
    public static func ReadInt16LittleEndian(buffer: [UInt8], offset: Int)throws -> Int16{
        guard (1 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        var bytes = [UInt8]()
        bytes.append(buffer[offset + 0])
        bytes.append(buffer[offset + 1])
        return toInt16(bytes: bytes)
    }
    
    public static func ReadInt32LittleEndian(buffer: [UInt8], offset: Int)throws -> Int32{
        guard (3 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        var bytes = [UInt8]()
        bytes.append(buffer[offset + 0])
        bytes.append(buffer[offset + 1])
        bytes.append(buffer[offset + 2])
        bytes.append(buffer[offset + 3])
        return toInt32(bytes: bytes)
    }
    
    public static func ReadUInt16LittleEndian(buffer: [UInt8], offset: Int)throws -> UInt16{
        guard (1 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        return UInt16((  ((UInt32(buffer[offset + 0])) << 0)
            |  ((UInt32(buffer[offset + 1])) << 8)))
    }
    
    public static func ReadUInt32LittleEndian(buffer: [UInt8], offset: Int)throws -> UInt32{
        guard (3 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        return ((  ((UInt32(buffer[offset + 0])) << 0)
            |  ((UInt32(buffer[offset + 1])) << 8)
            |  ((UInt32(buffer[offset + 2])) << 16)
            |  ((UInt32(buffer[offset + 3])) << 24)))
    }
    
//    public static func ReadUInt64LittleEndian(buffer: [UInt8], offset: Int)throws -> UInt64{
//        guard (7 + offset) < buffer.count else {
//            throw BufferAccessError.indexOutOfRange
//        }
//        return ((  ((UInt64(buffer[offset + 0])) << 0)
//            |  ((UInt64(buffer[offset + 1])) << 8)
//            |  ((UInt64(buffer[offset + 2])) << 16)
//            |  ((UInt64(buffer[offset + 3])) << 24)
//            |  ((UInt64(buffer[offset + 4])) << 32)
//            |  ((UInt64(buffer[offset + 5])) << 40)
//            |  ((UInt64(buffer[offset + 6])) << 48)
//            |  ((UInt64(buffer[offset + 7])) << 56)))
//    }
    
    public static func ReadInt8(buffer: [UInt8], offset: Int)throws -> Int8
    {
        guard (offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        return Int8.init(bitPattern: buffer[offset])
    }
    
    public static func ReadUInt8(buffer: [UInt8], offset: Int)throws -> UInt8
    {
        guard (offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        return buffer[offset]
    }
    
    //MARK: Read Big Endian
    public static func ReadInt16BigEndian(buffer: [UInt8], offset: Int)throws -> Int16{
        guard (1 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        var bytes = [UInt8]()
        bytes.append(buffer[offset + 1])
        bytes.append(buffer[offset + 0])
        
        return toInt16(bytes: bytes);
    }
    
    public static func ReadInt32BigEndian(buffer: [UInt8], offset: Int)throws -> Int32{
        guard (3 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        var bytes = [UInt8]()
        bytes.append(buffer[offset + 3])
        bytes.append(buffer[offset + 2])
        bytes.append(buffer[offset + 1])
        bytes.append(buffer[offset + 0])
        
        return toInt32(bytes: bytes)
    }
    
    public static func ReadUInt16BigEndian(buffer: [UInt8], offset: Int)throws -> UInt16{
        guard (1 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        return UInt16((  ((UInt32(buffer[offset + 1])) << 0)
            |  ((UInt32(buffer[offset + 0])) << 8)))
    }
    
    public static func ReadUInt32BigEndian(buffer: [UInt8], offset: Int)throws -> UInt32{
        guard (3 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        return ((  ((UInt32(buffer[offset + 3])) << 0)
            |  ((UInt32(buffer[offset + 2])) << 8)
            |  ((UInt32(buffer[offset + 1])) << 16)
            |  ((UInt32(buffer[offset + 0])) << 24)))
    }
    
//    public static func ReadUInt64BigEndian(buffer: [UInt8], offset: Int)throws -> UInt64{
//        guard (7 + offset) < buffer.count else {
//            throw BufferAccessError.indexOutOfRange
//        }
//        return ((  ((UInt64(buffer[offset + 7])) << 0)
//            |  ((UInt64(buffer[offset + 6])) << 8)
//            |  ((UInt64(buffer[offset + 5])) << 16)
//            |  ((UInt64(buffer[offset + 4])) << 24)
//            |  ((UInt64(buffer[offset + 3])) << 32)
//            |  ((UInt64(buffer[offset + 2])) << 40)
//            |  ((UInt64(buffer[offset + 1])) << 48)
//            |  ((UInt64(buffer[offset + 0])) << 56)))
//    }
    
    //MARK: Equals
    public static func Equals(buffer1: [UInt8], buffer2: [UInt8]) -> Bool
    {
        //Reference equals
        if buffer1 == buffer2{
            return true
        }
        
        //Length differs
        if buffer1.count != buffer2.count{
            return false
        }
        
        //Content differs
        for i in 0..<buffer1.count{
            if buffer1[i] != buffer2[i]{
                return false
            }
        }
        
        return true
    }
    
    //MARK: Write Little Endian
    public static func WriteInt16LittleEndian(data: Int16, buffer: inout [UInt8], offset: Int)throws{
        guard (1 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        let bytes: [UInt8] = GetBytes(data: data)
        buffer[offset + 0] = bytes[1]
        buffer[offset + 1] = bytes[0]
    }
    
    public static func WriteInt32LittleEndian(data: Int32, buffer: inout [UInt8], offset: Int)throws{
        guard (3 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        let bytes: [UInt8] = GetBytes(data: data)
        buffer[offset + 0] = bytes[3];
        buffer[offset + 1] = bytes[2];
        buffer[offset + 2] = bytes[1];
        buffer[offset + 3] = bytes[0];
    }
    
    public static func WriteUInt16LittleEndian(data: UInt16,  buffer: inout [UInt8], offset: Int)throws{
        guard (1 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        buffer[offset + 0] = UInt8((data & 0xFF))
        buffer[offset + 1] = UInt8((data >> 8) & 0xFF)
    }
    
    public static func WriteUInt32LittleEndian(data: UInt32, buffer: inout [UInt8], offset: Int)throws{
        guard (3 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        buffer[offset + 0] = UInt8((data & 0xFF))
        buffer[offset + 1] = UInt8((data >> 8) & 0xFF)
        buffer[offset + 2] = UInt8((data >> 16) & 0xFF)
        buffer[offset + 3] = UInt8((data >> 24) & 0xFF)
    }
    
    public static func WriteUInt64LittleEndian(data: UInt64, buffer: inout [UInt8], offset: Int)throws{
        guard (7 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        buffer[offset + 0] = UInt8((data & 0xFF))
        buffer[offset + 1] = UInt8((data >> 8) & 0xFF)
        buffer[offset + 2] = UInt8((data >> 16) & 0xFF)
        buffer[offset + 3] = UInt8((data >> 24) & 0xFF)
        buffer[offset + 4] = UInt8((data >> 32) & 0xFF)
        buffer[offset + 5] = UInt8((data >> 40) & 0xFF)
        buffer[offset + 6] = UInt8((data >> 48) & 0xFF)
        buffer[offset + 7] = UInt8((data >> 56) & 0xFF)
    }
    
    public static func WriteInt8(buffer: [UInt8], offset: Int)throws -> Int8
    {
        guard (offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        return Int8.init(bitPattern: buffer[offset])
    }
    
    public static func WriteUInt8(buffer: [UInt8], offset: Int)throws -> UInt8
    {
        guard (offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        return buffer[offset]
    }
    
    
    //MARK: Write Big Endian
    public static func WriteInt16BigEndian(data: Int16, buffer: inout [UInt8], offset: Int)throws{
        guard (1 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        let bytes: [UInt8] = GetBytes(data: data)
        buffer[offset + 0] = bytes[0]
        buffer[offset + 1] = bytes[1]
    }
    
    public static func WriteInt32BigEndian(data: Int32, buffer: inout [UInt8], offset: Int)throws{
        guard (3 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        let bytes: [UInt8] = GetBytes(data: data)
        buffer[offset + 0] = bytes[0];
        buffer[offset + 1] = bytes[1];
        buffer[offset + 2] = bytes[2];
        buffer[offset + 3] = bytes[3];
    }
    
    public static func WriteUInt16BigEndian(data: UInt16,  buffer: inout [UInt8], offset: Int)throws{
        guard (1 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        buffer[offset + 0] = UInt8((data >> 8) & 0xFF)
        buffer[offset + 1] = UInt8((data & 0xFF))
    }
    
    public static func WriteUInt32BigEndian(data: UInt32, buffer: inout [UInt8], offset: Int)throws{
        guard (3 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        buffer[offset + 0] = UInt8((data >> 24) & 0xFF)
        buffer[offset + 1] = UInt8((data >> 16) & 0xFF)
        buffer[offset + 2] = UInt8((data >> 8) & 0xFF)
        buffer[offset + 3] = UInt8((data & 0xFF))
    }
    
    public static func WriteUInt64BigEndian(data: UInt64, buffer: inout [UInt8], offset: Int)throws{
        guard (7 + offset) < buffer.count else {
            throw BufferAccessError.indexOutOfRange
        }
        buffer[offset + 0] = UInt8((data >> 56) & 0xFF)
        buffer[offset + 1] = UInt8((data >> 48) & 0xFF)
        buffer[offset + 2] = UInt8((data >> 40) & 0xFF)
        buffer[offset + 3] = UInt8((data >> 32) & 0xFF)
        buffer[offset + 4] = UInt8((data >> 24) & 0xFF)
        buffer[offset + 5] = UInt8((data >> 16) & 0xFF)
        buffer[offset + 6] = UInt8((data >> 8) & 0xFF)
        buffer[offset + 7] = UInt8((data & 0xFF))
    }
    
    
    //MARK private func
    private static func toInt32(bytes: [UInt8]) -> Int32
    {
        return bytes.withUnsafeBytes{ $0.baseAddress!.load(as: Int32.self)}
    }
    
    private static func toInt16(bytes: [UInt8]) -> Int16
    {
        return bytes.withUnsafeBytes{ $0.baseAddress!.load(as: Int16.self)}
    }
    
    private static func GetBytes(data: Int16) -> [UInt8]{
        let uInt16 = UInt16(bitPattern: data)
        
        let bytes: [UInt8] =
            [
                UInt8((uInt16 & 0xFF00) >> 8),
                UInt8(uInt16 & 0x00FF)
        ]
        
        return bytes
    }
    
    private static func GetBytes(data: Int32) -> [UInt8]{
        let uInt32 = UInt32(bitPattern: data)
        
        let bytes: [UInt8] =
            [
                UInt8((uInt32 & 0xFF000000) >> 24),
                UInt8((uInt32 & 0x00FF0000) >> 16),
                UInt8((uInt32 & 0x0000FF00) >> 8),
                UInt8(uInt32 & 0x000000FF)
        ]
        return bytes
    }
}

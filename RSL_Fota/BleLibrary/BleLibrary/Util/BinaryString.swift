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
 * Class Name: BinaryString.swift
 ******************************************************************************/

import Foundation
public struct BinaryString
{
    /**
     * Get the number of bytes encoded in a binary string
     */
    public static func getbyteCount(hexString: String) -> Int
    {
        var numHexChars = 0
        var c: Character?
        
        //remove all non A-F, 0-9 characters
        for i in 0..<hexString.count {
            
            c = hexString[i]
            if isHexDigit(c!)
            {
                numHexChars += 1
            }
            
        }
        
        if numHexChars % 2 != 0
        {
            numHexChars -= 1
        }
        
        return (numHexChars/2) //2 characters per byte
    }
    
    /**
     Creates a byte array from the hexadecimal string. Each two characters are combined to create one byte. First two hexadecimal characters become first byte in returned array Non-hexadecimal characters are ignored.
     
     - returns:
        Byte array, in the same left-to-right order asthe binary string.
     - parameters:
        - hexString: String to convert ot a byte array.
     
     - throws:
        - FormatError.InvalidFormat
     */
    public static func getBytes(hexString: String)throws -> [UInt8]
    {
        var discarded: Int = 0
        
        do
        {
            return try getBytes(hexString:hexString, discarded:&discarded)
        }
        catch let error
        {
            throw error
        }
    }
    
    /**
    Creates a byte array from the hexadecimal string. Each two characters are combined to create one byte. First two hexadecimal characters become first byte in returned array. Non-hexadecimal characters are ignored.
    
     - returns:
        Byte ([UInt8]) array, in the same left-to-right order as the binary string
     
     - parameters:
        - hexString: String to convert to a byte array
        - discarded: Number of characters in the string ignord
     
     - throws:
        - FormatError.InvalidFormat
     */
    public static func getBytes(hexString: String, discarded: inout Int )throws -> [UInt8]
    {
        var bytes:[UInt8] = [UInt8]()
        
        if !tryGetBytes(hexString: hexString, bytes: &bytes)
        {
            throw FormatError.InvalidFormat(message:"hex must be 1 or 2 characters in length")
        }
        
        return bytes
        
    }
    
    /**
     * Creates a byte array from the hexadecumal string. Each two characters are combined to create one byte. Firest two hexadecimal characters become first byte in returnd array. Non-hexadecimal characters are ignord
     
     - returns:
        True if the string has been converted, false if an error occurred
     
     - parameters:
        - hexString: String to convert to a byte array.
        - bytes: [UInt8] arary, in the same left-to-right order as the binary string.
     */
    public static func tryGetBytes(hexString: String, bytes: inout [UInt8]) -> Bool
    {
        var discarded: Int = 0
        return tryGetBytes(hexString: hexString, discarded:&discarded ,bytes: &bytes)
    }
    
    /**
     * Creates a byte array from the hexadecumal string. Each two characters are combined to create one byte. Firest two hexadecimal characters become first byte in returnd array. Non-hexadecimal characters are ignord
     
     - parameters:
        - hexString: String to convert to a byte array.
        - discarded: Number of characters in the string ignored
        - bytes: [UInt8] arary, in the same left-to-right order as the binary string.
     
     - returns:
        True if the string has been converted, false if an error occurred
     */
    public static func tryGetBytes(hexString: String, discarded: inout Int, bytes: inout [UInt8]) -> Bool
    {
        discarded = 0
        var buffer: [Character] = [Character](repeating: "0", count: 2)
        var hasCharInBuffer: Bool = false
    
        for c in hexString
        {
            if !isHexDigit(c)
            {
                discarded += 1
            }
            else if !hasCharInBuffer
            {
                buffer[0] = c
                hasCharInBuffer = true
            }
            else
            {
                buffer[1] = c
                hasCharInBuffer = false
                bytes.append(paraseHexValue(hex: buffer))
            }
        }
        
        if hasCharInBuffer
        {
            discarded += 1
        }
        
        return true
    }
    
    /**
     Build string of a given binary data
     - parameters:
        - buffer: Binary data to convert into a string
     
     - returns:
        String the represents the binary data
     */
    public static func toString(buffer:[UInt8]) -> String
    {
        return toString(buffer:buffer, offset:0, count:buffer.count, separator:"");
    }
    
    /**
     Build string of a given binary data
     
     - parameters:
        - buffer: Binary data to convert into a string
        - offset: Offset of the data to convert in the buffer
        - count: Number of bytes to be represented by the string
     
     - returns
        String the represents the binary data
     */
    public static func toString(buffer:[UInt8], offset:Int, count:Int) -> String
    {
        return toString(buffer:buffer, offset:offset, count:count, separator:"")
    }
    
    /**
     Build string of a given binary data
    
     - parameters:
        - buffer: Binary data to convert into a string
        - offset: Offset of the data to convert in the buffer
        - count: Number of bytes to be represented by the string
        - separator: Separator string in the output between two bytes
     
     - returns:
        String the represents the binary data
     */
    public static func toString(buffer:[UInt8], offset:Int, count:Int, separator:String) -> String
    {
        let builder: NSMutableString = NSMutableString()
        
        for i in 0..<count{
            if(builder.length > 0)
            {
                builder.append(separator)
            }
            builder.append(String(format: "%02X", buffer[offset + i]))
        }
        
        return builder as String
    }
    
    /**
     Determines if given string is in proper headecimal string format
    
     - parameters:
        - hexString: String to check for HEX format
     
     - returns:
        true if it is a hex string, otherwise false
     */
    public static func inHexFormat(hexString: String) -> Bool
    {
        var hexFormat = true
    
        for c in hexString
        {
            if !isHexDigit(c)
            {
                hexFormat = false
                break
            }
        }
        return hexFormat
    }
    
    private static func paraseHexValue(hex: [Character]) -> UInt8    {
        
        var hex = String(hex)
        
        let subIndex = hex.index(hex.startIndex, offsetBy: 2)
        let c = String(hex[..<subIndex])
        hex = String(hex[subIndex...])
        var ch: UInt32 = 0
        Scanner(string: c).scanHexInt32(&ch)
            
        return UInt8(ch)
    }
    
    private static func isHexDigit(_ c: Character) -> Bool
    {
        let digits = "abcdefABCDEF1234567890"
        
        return digits.contains(c)
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

enum FormatError: Error
{
    case InvalidFormat(message: String)
}


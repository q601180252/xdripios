import Foundation
import os

// sourcre https://github.com/gui-dos/DiaBLE

public enum LibreSensorType: String {
    
    // Libre 1
    case libre1 = "libre1"
    
    case libreUS14day = "libreUS14day"
    
    case libreProH = "libreProH"

    case libre2 = "libre2"
            
    case libre2Plus = "libre2Plus"
    
    case libre2US = "libre2US"

    case libre2CA = "libre2CA"

    case libre2RU = "libre2RU"

    case libreSense = "libreSense"
    
    case libre3 = "libre3"
    
    case unsupported
    
    var description: String {
        switch self {
        case .libre1, .libreUS14day:
            return "Libre 1"
        case .libreProH:
            return "Libre PRO H"
        case .libre2:
            return "Libre 2"
        case .libre2Plus:
            return "Libre 2 Plus"
        case .libre2US:
            return "Libre 2 US"
        case .libre2CA:
            return "Libre 2 CA"
        case .libre2RU:
            return "Libre 2 RU"
        case .libreSense:
            return "Libre Sense"
        case .libre3:
            return "Libre 3"
            
        case .unsupported:
            return TextsLibreStates.unsupported
        default:
            return ""
        }
    }
        
    /// decrypts for libre2 and libreUs,
    func decryptIfPossibleAndNeeded(rxBuffer:inout Data, headerLength: Int, log: OSLog?, patchInfo: String?, uid: [UInt8]) -> Bool {
        
        // index of last byte to process
        let rxBufferEnd = headerLength + 344 - 1
        
        // rxBuffer size should be at least headerLength + 344, if not don't further process
        guard rxBuffer.count >= headerLength + 344 else {
            return false
        }
        
        // decrypt if libre2 or libreUS
        if self == .libre2 || self == .libre2US {
            
            var libreData = rxBuffer.subdata(in: headerLength..<(rxBufferEnd + 1))

            if let info = patchInfo?.hexadecimal() {
                
                if let log = log {
                    trace("    decrypting libre data", log: log, category: ConstantsLog.categoryLibreSensorType, type: .info)
                }
                //TODO2
//                libreData = Data(PreLibre2.decryptFRAM(uid, info.bytes, libreData.bytes))
                
            } else {
                
                return false
                
            }
            
            // replace 344 bytes to Decrypted data
            rxBuffer.replaceSubrange(headerLength..<(rxBufferEnd + 1), with: libreData)
            
            return true

        }
        
        return false
        
    }
    
    /// checks crc if needed for the sensor type
    func crcIsOk(rxBuffer:inout Data, headerLength: Int, log: OSLog?) -> Bool {
        
        guard Crc.LibreCrc(data: &rxBuffer, headerOffset: headerLength, libreSensorType: self) else {
            
            if let log = log {
                trace("    in crcIsOk, CRC check failed", log: log, category: ConstantsLog.categoryCGMBubble, type: .info)
            }
            
            return false
        }

        return true

    }

    /// - reads the first byte in patchInfo and dependent on that value, returns type of sensor
    /// - if patchInfo = nil, then returnvalue is Libre1
    /// - if first byte is unknown, then returns nil
    static func type(patchInfo: String?) -> LibreSensorType? {
        
        guard let pathInfoData = patchInfo?.hexadecimal() else {return nil}
        
        guard pathInfoData.count > 1 else { return nil }
        
        switch pathInfoData[0] {
        case 0xDF, 0xA2:
            return .libre1
        case 0xE5, 0xE6:
            return .libreUS14day
        case 0x70:
            return .libreProH
        case 0x9D, 0xC5:
            return .libre2
        case 0xC6, 0x2C:
            return .libre2Plus
            
        case 0x76, 0x2B:
            if pathInfoData[3] == 2 {
                return .libre2US
            } else if pathInfoData[3] == 4 {
                return .libre2CA
            } else if pathInfoData[3] == 8 {
                if pathInfoData[2] & 0x0F < 0x0A {
                    return .libre2RU
                } else {
                    return .libre2Plus
                }
            } else if pathInfoData[2] >> 4 == 7 {
                return .libreSense
            }
                        
        default:
            if pathInfoData.count == 24 {
                return .libre3
            }
        }
        
        return nil
}
    
    /// maximum sensor age in days, nil if no maximum
    func maxSensorAgeInDays() -> Double? {
        switch self {
        case .libre1:
            return 14.5
        case .libre2, .libreSense:
            return 14.5
        case .libreProH:
            return 14
        case .libreUS14day:
            return 14
        case .libre2Plus, .libre2US, .libre2CA, .libre2RU, .libre3:
            return nil
        default:
            return nil
        }
    }

}



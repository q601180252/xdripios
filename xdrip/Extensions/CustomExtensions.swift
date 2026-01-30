import UIKit

public extension UIColor {
    static let modena = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
    static let pinkRed = UIColor(red: 1.0, green: 0.176, blue: 0.333, alpha: 1.0)
    static let grayProgress = UIColor.lightGray
}

public struct TextsSetting {
    public static let upgrade = NSLocalizedString("Upgrade", comment: "")
}

public struct UserDefaultsUnit {
    public static var mac: String? {
        get {
            return UserDefaults.standard.string(forKey: "fota_mac_address")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "fota_mac_address")
        }
    }
}

public extension UIActivityIndicatorView {
    func applyGradient(colors: [UIColor]) {
        // Dummy implementation to fix compilation
    }
    
    func removeGradient() {
        // Dummy implementation to fix compilation
    }
}

// Support for legacy Fota code
public struct K {
    public static let cellNibName = "DeviceCell"
    public static let cellIdentifier = "ReusableCell"
    public static let controlView = "ControlView"
    public static let settingsView = "SettingsView"
}

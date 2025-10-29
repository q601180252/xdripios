import UIKit

class BubbleBluetoothPeripheralViewModel {
    
    // MARK: - private properties
    
    /// settings specific for bubble
    private enum Settings:Int, CaseIterable {
        
        /// Libre sensor type
        case sensorType = 0
        
        /// Sensor serial number
        case sensorSerialNumber = 1
        
        /// sensor State
        case sensorState = 2
        
        /// battery level
        case batteryLevel = 3
        
        /// firmware version
        case firmWare = 4
        
        /// hardware version
        case hardWare = 5
        
        /// battery logs
        case batteryLog = 6
        
    }
    
    /// Bubble settings willb be in section 0 + numberOfGeneralSections
    private let sectionNumberForBubbleSpecificSettings = 0
    
    /// reference to bluetoothPeripheralManager
    private weak var bluetoothPeripheralManager: BluetoothPeripheralManaging?
    
    /// reference to the tableView
    private weak var tableView: UITableView?
    
    /// reference to BluetoothPeripheralViewController that will own this BubbleBluetoothPeripheralViewModel - needed to present stuff etc
    private weak var bluetoothPeripheralViewController: BluetoothPeripheralViewController?
    
    /// temporary reference to bluetoothPerpipheral, will be set in configure function.
    private var bluetoothPeripheral: BluetoothPeripheral?
    
    /// it's the bluetoothPeripheral as Bubble
    private var bubble: Bubble? {
        get {
            return bluetoothPeripheral as? Bubble
        }
    }
    
    private let otaFetcher = NanoOTAFetcher()
        
    // MARK: - deinit
    
    deinit {

        // when closing the viewModel, and if there's still a bluetoothTransmitter existing, then reset the specific delegate to BluetoothPeripheralManager
        
        guard let bluetoothPeripheralManager = bluetoothPeripheralManager else {return}
        
        guard let bubble = bubble else {return}
        
        guard let blueToothTransmitter = bluetoothPeripheralManager.getBluetoothTransmitter(for: bubble, createANewOneIfNecesssary: false) else {return}
        
        guard let cGMBubbleBluetoothTransmitter = blueToothTransmitter as? CGMBubbleTransmitter else {return}
        
        cGMBubbleBluetoothTransmitter.cGMBubbleTransmitterDelegate = bluetoothPeripheralManager as! BluetoothPeripheralManager

    }
    
}

// MARK: - conform to BluetoothPeripheralViewModel

extension BubbleBluetoothPeripheralViewModel: BluetoothPeripheralViewModel {

    func configure(bluetoothPeripheral: BluetoothPeripheral?, bluetoothPeripheralManager: BluetoothPeripheralManaging, tableView: UITableView, bluetoothPeripheralViewController: BluetoothPeripheralViewController) {
        
        self.bluetoothPeripheralManager = bluetoothPeripheralManager
        
        self.tableView = tableView
        
        self.bluetoothPeripheralViewController = bluetoothPeripheralViewController
        
        self.bluetoothPeripheral = bluetoothPeripheral
        
        if let bluetoothPeripheral = bluetoothPeripheral {
            
            if let bubble = bluetoothPeripheral as? Bubble {
                
                if let blueToothTransmitter = bluetoothPeripheralManager.getBluetoothTransmitter(for: bubble, createANewOneIfNecesssary: false), let cGMBubbleTransmitter = blueToothTransmitter as? CGMBubbleTransmitter {
                    
                    // set CGMBubbleTransmitter delegate to self.
                    cGMBubbleTransmitter.cGMBubbleTransmitterDelegate = self
                    
                }
                
            } else {
                fatalError("in BubbleBluetoothPeripheralViewModel, configure. bluetoothPeripheral is not Bubble")
            }
        }

    }
    
    func screenTitle() -> String {
        return BluetoothPeripheralType.BubbleType.rawValue
    }
    
    func sectionTitle(forSection section: Int) -> String {
        return BluetoothPeripheralType.BubbleType.rawValue
    }
    
    func update(cell: UITableViewCell, forRow rawValue: Int, forSection section: Int, for bluetoothPeripheral: BluetoothPeripheral) {
        
        // verify that bluetoothPeripheral is a Bubble
        guard let bubble = bluetoothPeripheral as? Bubble else {
            fatalError("BubbleBluetoothPeripheralViewModel update, bluetoothPeripheral is not Bubble")
        }
        
        // default value for accessoryView is nil
        cell.accessoryView = nil

        // create disclosureIndicator in color ConstantsUI.disclosureIndicatorColor
        // will be used whenever accessoryType is to be set to disclosureIndicator
        let  disclosureAccessoryView = DTCustomColoredAccessory(color: ConstantsUI.disclosureIndicatorColor)

        guard let setting = Settings(rawValue: rawValue) else { fatalError("BubbleBluetoothPeripheralViewModel update, unexpected setting") }
        
        switch setting {
            
        case .batteryLevel:
            
            cell.textLabel?.text = Texts_BluetoothPeripheralsView.batteryLevel
            if bubble.batteryLevel > 0 {
                cell.detailTextLabel?.text = bubble.batteryLevel.description + " %"
            } else {
                cell.detailTextLabel?.text = ""
            }
            cell.accessoryType = .none
            
        case .firmWare:
            
            cell.textLabel?.text = Texts_Common.firmware
            cell.detailTextLabel?.text = otaFetcher.display(bubble.firmware)
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView =  disclosureAccessoryView
            
        case .hardWare:
            
            cell.textLabel?.text = Texts_Common.hardware
            cell.detailTextLabel?.text = bubble.hardware
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView =  disclosureAccessoryView
            
        case .sensorSerialNumber:
            
            cell.textLabel?.text = Texts_BluetoothPeripheralView.sensorSerialNumber
            
            if let type = bubble.blePeripheral.libreSensorType, type != .unsupported, let sensorSerialNumber = bubble.blePeripheral.sensorSerialNumber {
                
                cell.detailTextLabel?.text = sensorSerialNumber
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView =  disclosureAccessoryView

            } else {
                cell.accessoryType = .none
                cell.detailTextLabel?.text = "-"
            }
            
        case .sensorType:
            
            cell.accessoryType = .none
            
            cell.textLabel?.text = Texts_BluetoothPeripheralView.sensorType
            
            if let libreSensorType = bubble.blePeripheral.libreSensorType {
                
                cell.detailTextLabel?.text = libreSensorType.description
                
            } else {
                
                cell.detailTextLabel?.text = Texts_HomeView.noSensorData
            }
            
        case .sensorState:
            
            cell.accessoryType = .none
            
            cell.textLabel?.text = Texts_Common.sensorStatus
            
            if let libreSensorType = bubble.blePeripheral.libreSensorType, libreSensorType != .unsupported {
                
                cell.detailTextLabel?.text = bubble.sensorState.translatedDescription

            } else {
                
                cell.detailTextLabel?.text = "-"
            }
            
        case .batteryLog:
            
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView =  disclosureAccessoryView

            cell.textLabel?.text = Texts_Common.batteryLog
            
            cell.detailTextLabel?.text = ""
        }

    }
    
    func userDidSelectRow(withSettingRawValue rawValue: Int, forSection section: Int, for bluetoothPeripheral: BluetoothPeripheral, bluetoothPeripheralManager: BluetoothPeripheralManaging) -> SettingsSelectedRowAction {
        
        // verify that bluetoothPeripheral is a Bubble
        guard let bubble = bluetoothPeripheral as? Bubble else {
            fatalError("BubbleBluetoothPeripheralViewModel userDidSelectRow, bluetoothPeripheral is not Bubble")
        }
        
        guard let setting = Settings(rawValue: rawValue) else { fatalError("BubbleBluetoothPeripheralViewModel userDidSelectRow, unexpected setting") }
        
        switch setting {
            
        case .batteryLevel, .sensorType, .sensorState:
            return .nothing
            
        case .firmWare:
            
            // firmware text could be longer than screen width, clicking the row allos to see it in pop up with more text place
            if let otaFile = otaFetcher.latestFotaFile, bubble.blePeripheral.name.lowercased().contains("nano"), otaFetcher.hasNewVersion(bubble.firmware) {
                return .performSegue(withIdentifier: "showOTA", sender: otaFile)
            } else {
                if let firmware = bubble.firmware {
                    return .showInfoText(title: Texts_HomeView.info, message: Texts_Common.firmware + ": " + firmware)
                }
            }
            
        case .hardWare:

            // hardware text could be longer than screen width, clicking the row allows to see it in pop up with more text place
            if let hardware = bubble.hardware {
                return .showInfoText(title: Texts_HomeView.info, message: Texts_Common.hardware + ": " + hardware)
            }
            
        case .sensorSerialNumber:
            
            // serial text could be longer than screen width, clicking the row allows to see it in a pop up with more text place
            if let type = bubble.blePeripheral.libreSensorType, type != .unsupported, let serialNumber = bubble.blePeripheral.sensorSerialNumber {
                return .showInfoText(title: Texts_HomeView.info, message: Texts_BluetoothPeripheralView.sensorSerialNumber + " " + serialNumber)
            }
            
        case .batteryLog:
            
            return .performSegue(withIdentifier: "showBatteryLog", sender: nil)
        }
        
        return .nothing

    }
    
    func numberOfSettings(inSection section: Int) -> Int {
        return Settings.allCases.count
    }
    
    func numberOfSections() -> Int {
        // for the moment only one specific section for DexcomG5
        return 1
    }
    
}

// MARK: - conform to CGMBubbleTransmitterDelegate

extension BubbleBluetoothPeripheralViewModel: CGMBubbleTransmitterDelegate {
    
    func received(batteryLevel: Int, from cGMBubbleTransmitter: CGMBubbleTransmitter) {
        
        // inform also bluetoothPeripheralManager
        (bluetoothPeripheralManager as? CGMBubbleTransmitterDelegate)?.received(batteryLevel: batteryLevel, from: cGMBubbleTransmitter)
        
        // here's the trigger to update the table
        reloadRow(row: Settings.batteryLevel.rawValue)

    }
    
    func received(sensorStatus: LibreSensorState, from cGMBubbleTransmitter: CGMBubbleTransmitter) {
        
        // inform also bluetoothPeripheralManager
        (bluetoothPeripheralManager as? CGMBubbleTransmitterDelegate)?.received(sensorStatus: sensorStatus, from: cGMBubbleTransmitter)
        
        // here's the trigger to update the table
        reloadRow(row: Settings.sensorState.rawValue)
        
    }
    
    func received(serialNumber: String, from cGMBubbleTransmitter: CGMBubbleTransmitter) {
        
        // inform also bluetoothPeripheralManager
        (bluetoothPeripheralManager as? CGMBubbleTransmitterDelegate)?.received(serialNumber: serialNumber, from: cGMBubbleTransmitter)
     
        DispatchQueue.main.async { [weak self] in
            // here's the trigger to update the table
            self?.reloadRow(row: Settings.sensorSerialNumber.rawValue)

        }

    }
    
    func received(firmware: String, from cGMBubbleTransmitter: CGMBubbleTransmitter) {
        
        // inform also bluetoothPeripheralManager
        (bluetoothPeripheralManager as? CGMBubbleTransmitterDelegate)?.received(firmware: firmware, from: cGMBubbleTransmitter)
        
        // here's the trigger to update the table
        reloadRow(row: Settings.firmWare.rawValue)
        
    }
    
    func received(hardware: String, from cGMBubbleTransmitter: CGMBubbleTransmitter) {
        
        // inform bluetoothPeripheralManager, bluetoothPeripheralManager will store the hardware in the bubble object
        (bluetoothPeripheralManager as? CGMBubbleTransmitterDelegate)?.received(hardware: hardware, from: cGMBubbleTransmitter)
        
        // here's the trigger to update the table
        reloadRow(row: Settings.hardWare.rawValue)
        
    }
    
    func received(libreSensorType: LibreSensorType, from cGMBubbleTransmitter: CGMBubbleTransmitter) {
        
        // inform bluetoothPeripheralManager, bluetoothPeripheralManager will store the libreSensorType in the bubble object
        (bluetoothPeripheralManager as? CGMBubbleTransmitterDelegate)?.received(libreSensorType: libreSensorType, from: cGMBubbleTransmitter)

        // here's the trigger to update the table row for sensorType
        reloadRow(row: Settings.sensorType.rawValue)
        
    }
    
    private func reloadRow(row: Int) {
        
        if let bluetoothPeripheralViewController = bluetoothPeripheralViewController {
            
            tableView?.reloadRows(at: [IndexPath(row: row, section: bluetoothPeripheralViewController.numberOfGeneralSections() + sectionNumberForBubbleSpecificSettings)], with: .none)
        
        }
    }
    
}

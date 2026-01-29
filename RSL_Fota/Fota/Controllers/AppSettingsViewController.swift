/*
* Copyright © 2021, Semiconductor Components Industries, LLC
* (d/b/a ON Semiconductor). All rights reserved.
*
* This code is the property of ON Semiconductor and may not be redistributed
* in any form without prior written permission from ON Semiconductor.
* The terms of use and warranty for this code are covered by contractual
* agreements between ON Semiconductor and the licensee.
*
* This is Reusable Code
*
* Class Name: AppSettingsViewController.swift
*/

import UIKit
import CoreBluetooth

class AppSettingsViewController: UITableViewController, UITextFieldDelegate {
    
    //MARK: - Members
    
    private var temperatureValue: String?
    private var checked: Bool?
    let defaults = UserDefaults.standard
    let dictionary = Bundle.main.infoDictionary!
  
    @IBOutlet weak var manufacturerDataSelected: UIButton!
    @IBOutlet weak var deviceName: UITextField!
    
    @IBOutlet weak var versionNumber: UILabel!
    @IBOutlet weak var buildNumber: UILabel!
    
    //MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        if let peripheralName = defaults.string(forKey: "peripheralName"){
            deviceName.text = peripheralName
        }
       
        manufacturerDataSelected.isSelected = defaults.bool(forKey: "manufacturerData")
        
        deviceName.layer.borderWidth = 1
        deviceName.layer.borderColor = #colorLiteral(red: 0.7100608349, green: 0.7301132679, blue: 0.7511115074, alpha: 1)
        deviceName.delegate = self
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        versionNumber.text = "V\(version)"
        buildNumber.text = build
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButton()
    }
    
    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: UITextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
        textField.layer.borderColor = #colorLiteral(red: 0.8549019608, green: 0.4980392157, blue: 0.2352941176, alpha: 1)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == deviceName{
            textField.placeholder = "E.G. ble_periph_server"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return true
        
    }
    
    //MARK: - TableView Method
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = #colorLiteral(red: 0.8549019608, green: 0.4980392157, blue: 0.2352941176, alpha: 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < 3 {
            return 50.0
        }else{
            return UITableView.automaticDimension
        }
    }
    
    //MARK: - IB Action Method for the Apply Button
    
    @IBAction func applySettings(_ sender: Any) {
        defaults.setValue(checked, forKey: "manufacturerData")
        defaults.setValue(deviceName.text, forKey: "peripheralName")
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - IB Action Method for Manufacturer Specific Data CheckBox
    
    @IBAction func manufacturerSpecificDataEnable(_ sender: UIButton) {
        if sender.isSelected {
                    sender.isSelected = false
                    checked = false
                } else {
                    sender.isSelected = true
                    checked = true
                }
    }
    
    //MARK: - Private function
    
    private func backButton(){
        let backBarButton = UIBarButtonItem(withCustomType: .backButton,
                                            target: self,
                                            action: #selector(AppSettingsViewController.backButtonAction))
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
}

/*
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
 * Class Name: PeripheralTableViewController.swift
 */

import FotaLibrary
import BleLibrary
import Foundation
import UIKit

class PeripheralTableViewController: UITableViewController {
    
    private struct K {
        static let cellNibName = "DeviceCell"
        static let cellIdentifier = "ReusableCell"
        static let controlView = "ControlView"
        static let settingsView = "SettingsView"
    }
    
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    //MARK: Properties
    var peripherals = [FotaPeripheral]()
    
    //MARK: members
    var manager: FotaPeripheralManager = (UIApplication.shared.delegate as! AppDelegate).peripheralManager
    
    //MARK: eventhandlers
    private var _bleProducListChangedHandler: EventHandlerProtocol?
    private var _isBusyHandler: EventHandlerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 48
        tableView.separatorStyle = .none
        progressView.isHidden = true
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        (UIApplication.shared.delegate as! AppDelegate).peripheralManager.onPauseScan = { [weak self] in
            DispatchQueue.main.async {
                self?.EndRefresh()
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).peripheralManager.onBluetoothOn = { [weak self] in
            DispatchQueue.main.async {
                self?.showGradientAnimation(flag: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Register events
        registerEvents()
        
                // if a peripheral is selected, teardown and dispose
                if (UIApplication.shared.delegate as! AppDelegate).peripheralManager.selected != nil
                {
                    do{
                        try (UIApplication.shared.delegate as! AppDelegate).peripheralManager.selected?.teardown()
                        (UIApplication.shared.delegate as! AppDelegate).peripheralManager.selected?.dispose()
                        (UIApplication.shared.delegate as! AppDelegate).peripheralManager.selected = nil
                    }
                    catch
                    {
                        //Ignore error
                    }
                }
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Searching for peripherals")
        refreshControl?.addTarget(self, action: #selector(refreshPeripheralList(_:)), for: .valueChanged)
        
        refreshPeripheralList(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshControl?.endRefreshing()
    }
        
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return peripherals.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cell are reused and should be dequeued using a cell identifier
        
        guard let cell: DeviceCell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as? DeviceCell else {
            return UITableViewCell()
        }
        // Feches the appropriate peripheral for the data source layout
        let peripheral = peripherals[indexPath.row]    
        cell.configure(withName: peripheral.name, withUUID: peripheral.uuid.uuidString, rssiValue: NSNumber(value: Int(peripheral.rssi.description) ?? 0))
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.updateLayoutsIfNeccessary()
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: K.controlView, sender: peripherals[indexPath.row])
    }
    
    // MARK: - Segue and navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return identifier == K.controlView || identifier == K.settingsView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == K.controlView {
            if let peripheral = sender as? FotaPeripheral {
                _ = segue.destination as! BleDeviceViewController
                
                (UIApplication.shared.delegate as! AppDelegate).peripheralManager.stopScan()
                (UIApplication.shared.delegate as! AppDelegate).peripheralManager.selected = peripheral
                
                deregisterEvents()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        EndRefresh()
    }
    
    //MARK: Events
    func onBleListChanged(args: EmptyEventArgs)
    {
        DispatchQueue.main.async {
            self.peripherals = (UIApplication.shared.delegate as! AppDelegate).peripheralManager.peripherals;
            self.tableView.reloadData()
        }
    }
    
    func onIsBusyChanged(args: IsBusyEventArgs)
    {
        if !args.isBusy
        {
            EndRefresh()
        }
        else{
            showGradientAnimation(flag: true)
        }
        // UIApplication.shared.isNetworkActivityIndicatorVisible = args.isBusy
    }
    
    //MARK: Private functions
    
    @objc private func refreshPeripheralList(_ sender: Any)
    {
        do{
            // if (UIApplication.shared.delegate as! AppDelegate) != nil
            // {
                (UIApplication.shared.delegate as! AppDelegate).peripheralManager.selected?.dispose()
                (UIApplication.shared.delegate as! AppDelegate).peripheralManager.selected = nil
            // }
            (UIApplication.shared.delegate as! AppDelegate).peripheralManager.onBluetoothOff = { [weak self] in
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Bluetooth Disabled", message: "The app needs bluetooth to be enabled to work correctly", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        alert.dismiss(animated: true, completion: nil)
                        self?.EndRefresh()
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            
            
            try (UIApplication.shared.delegate as! AppDelegate).peripheralManager.clear()
            
            if((UIApplication.shared.delegate as! AppDelegate).peripheralManager.isBluetoothEnabled())
            {
                // Start scaning for peripherals
                (UIApplication.shared.delegate as! AppDelegate).peripheralManager.startScan()
                showGradientAnimation(flag: true)
                print("scan started")
            }
            refreshControl?.endRefreshing()
        }
        catch
        {
            //ignore error
        }
    }
    
    private func EndRefresh()
    {
        refreshControl?.endRefreshing()
        showGradientAnimation(flag: false)
    }
    
    func showGradientAnimation(flag: Bool) {
        if flag == true {
            progressView.startAnimating()
        } else {
            progressView.stopAnimating()
        }
    }

    func updateNavigationBar()
    {
        if  manager.selected?.state == PeripheralState.idle
        {
            // UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            backEnabledButton()
        }
        
        if  manager.selected?.state == PeripheralState.update || manager.selected?.state == PeripheralState.establishLink
        {
            // UIApplication.shared.isNetworkActivityIndicatorVisible = true;
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            backDisabledButton()
        }
    }
    
    private func registerEvents()
    {
        _bleProducListChangedHandler = (UIApplication.shared.delegate as! AppDelegate).peripheralManager.eventBleProductListChanged.addHandler(self, PeripheralTableViewController.onBleListChanged)
        _isBusyHandler = (UIApplication.shared.delegate as! AppDelegate).peripheralManager.eventIsBusyChanged.addHandler(self, PeripheralTableViewController.onIsBusyChanged)
    }
    
    private func deregisterEvents()
    {
        _bleProducListChangedHandler?.dispose()
        _isBusyHandler?.dispose()
    }
    
    //MARK: Open Settings Navigation
    
    @IBAction func openSettings(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.settingsView, sender: self)
    }

    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }

    private func backEnabledButton(){
        let backBarButton = UIBarButtonItem(withCustomType: .backButton,
                                            target: self,
                                            action: #selector(PeripheralTableViewController.backButtonAction))
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    private func backDisabledButton(){
        let backBarButton = UIBarButtonItem(withCustomType: .backDisabledButton,
                                            target: self,
                                            action: #selector(PeripheralTableViewController.backButtonAction))
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
}

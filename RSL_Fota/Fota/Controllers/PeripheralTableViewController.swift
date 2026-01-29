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

class PeripheralTableViewController: UITableViewController {
    
    @IBOutlet weak var progressView: ProgressView!
    //MARK: Properties
    var peripherals = [FotaPeripheral]()
    
    //MARK: members
    var manager: FotaPeripheralManager = AppDelegate.shared().peripheralManager
    
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
        AppDelegate.shared().peripheralManager.onPauseScan = { [weak self] in
            DispatchQueue.main.async {
                self?.EndRefresh()
            }
        }
        AppDelegate.shared().peripheralManager.onBluetoothOn = { [weak self] in
            DispatchQueue.main.async {
                self?.showGradientAnimation(flag: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Register events
        registerEvents()
        
                // if a peripheral is selected, teardown and dispose
                if AppDelegate.shared().peripheralManager.selected != nil
                {
                    do{
                        try AppDelegate.shared().peripheralManager.selected?.teardown()
                        AppDelegate.shared().peripheralManager.selected?.dispose()
                        AppDelegate.shared().peripheralManager.selected = nil
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
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
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
                
                AppDelegate.shared().peripheralManager.stopScan()
                AppDelegate.shared().peripheralManager.selected = peripheral
                
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
            self.peripherals = AppDelegate.shared().peripheralManager.peripherals;
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = args.isBusy
    }
    
    //MARK: Private functions
    
    @objc private func refreshPeripheralList(_ sender: Any)
    {
        do{
            if AppDelegate.shared() != nil
            {
                AppDelegate.shared().peripheralManager.selected?.dispose()
                AppDelegate.shared().peripheralManager.selected = nil
            }
            AppDelegate.shared().peripheralManager.onBluetoothOff = { [weak self] in
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Bluetooth Disabled", message: "The app needs bluetooth to be enabled to work correctly", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        alert.dismiss(animated: true, completion: nil)
                        self?.EndRefresh()
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            
            
            try AppDelegate.shared().peripheralManager.clear()
            
            if(AppDelegate.shared().peripheralManager.isBluetoothEnabled())
            {
                // Start scaning for peripherals
                AppDelegate.shared().peripheralManager.startScan()
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
            progressView.applyGradient()
        } else {
            progressView.removeGradient()
        }
    }
    
    private func registerEvents()
    {
        _bleProducListChangedHandler = AppDelegate.shared().peripheralManager.eventBleProductListChanged.addHandler(self, PeripheralTableViewController.onBleListChanged)
        _isBusyHandler = AppDelegate.shared().peripheralManager.eventIsBusyChanged.addHandler(self, PeripheralTableViewController.onIsBusyChanged)
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
    
}

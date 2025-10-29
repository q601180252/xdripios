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
 * Class Name: BleDeviceViewController.swift
 */

import FotaLibrary
import BleLibrary
import UIKit
import Foundation

class BleDeviceViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    deinit {
        print("ble device view controller deinit")
    }
    
    let manager: FotaPeripheralManager = FotaPeripheralManager(true)
    var fotaFile: FotaFile? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.versionLabel.text = self?.fotaFile?.AppImage.version.imageVersion ?? "-"
                self?.manager.stopScan()

                if let currentVersion = self?.firmware, let latestVersion = self?.fotaFile?.AppImage.version.imageVersion {
                    if self?.compare(version1: latestVersion, greaterThan: currentVersion) == true {

                        self?.progressBar.isHidden = false
                        self?.latestVersionLabel.isHidden = true

                        self?.updateButtons()
//                        self?.prepare()

                    } else {
                        try? self?.manager.selected?.connectThenDisconnect()
                    }
                }
            }
        }
    }
    
    //MARK: eventhandlers
    private var _progressHandler: EventHandlerProtocol?
    private var _completedHandler: EventHandlerProtocol?
    
    public var firmware: String?
    public var address: String?
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
        
    @IBOutlet weak var progressBar: CircularProgressView!
    @IBOutlet weak var updateButton: RoundButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var currentVersionLabel: UILabel!
    @IBOutlet weak var latestVersionLabel: UILabel!
    
    //MARK: members
    private var throughputTimer: Timer? = nil
    private var controller: FotaController?
    private var currentProgress: Int? = 0
    private var lastProgress: Int? = nil
    private var currentStep: FotaUpdateStep = FotaUpdateStep.idle
    private var progressLock = DispatchQueue(label: "com.outshine.fota.BleDeviceViewController.progressLock", attributes:  .concurrent)
    private var runQueue = DispatchQueue(label: "fota.RunQueue")
    private var throughput: Double = 0.0
    private let log: LogProtocol = LogManager.manager.createLog(name: "BleDeviceViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressBar.progress = 0
                
        initButtons()
        
        currentVersionLabel.text = firmware ?? "-"

        progressBar.isHidden = true
        latestVersionLabel.isHidden = false
    }
        
    //MARK: eventhandlers
    private var _bleProducListChangedHandler: EventHandlerProtocol?
    private var _isBusyHandler: EventHandlerProtocol?
    private var _stateChangedHandler: EventHandlerProtocol?
    
    private func registerEvents()
    {
        _bleProducListChangedHandler = manager.eventBleProductListChanged.addHandler(self, BleDeviceViewController.onBleListChanged)
        _isBusyHandler = manager.eventIsBusyChanged.addHandler(self, BleDeviceViewController.onIsBusyChanged)
    }
    
    private func deregisterEvents()
    {
        _bleProducListChangedHandler?.dispose()
        _isBusyHandler?.dispose()
    }
    
    func onBleListChanged(args: EmptyEventArgs)
    {
        DispatchQueue.main.async { [weak self] in
            guard let s = self else { return }
            
            let peripherals = s.manager.peripherals
            guard peripherals.count > 0 else { return }
            
            s.manager.selected = peripherals.filter({ $0.peripheral?.uuid.uuidString == s.address }).first
            
            if s.manager.selected != nil {
                s.manager.stopScan()
                
                s.registerDeviceEvents()
                s.prepare()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6)) { [weak self] in
                    self?.connect()
                }
            }

            peripherals.filter({ $0.name == "B3_OTA" }).forEach { p in
                try? p.connectThenDisconnect()
            }
        }
    }
    
    func onIsBusyChanged(args: IsBusyEventArgs)
    {
        if !args.isBusy {
            /*EndRefresh*/()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = args.isBusy
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backEnabledButton()
        registerEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        manager.startScan()
//        if let currentVersion = manager.selected?.peripheral?.manufacturerData.parse()?.firmware {
//            let latestVersion = fotaFile.AppImage.version.imageVersion
//            
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        manager.stopScan()
        
        deregisterEvents()
        deregisterDeviceEvents()
        
        try? manager.selected?.connectThenDisconnect()
    }
    
    @objc func backButtonAction() {
        beforeExit()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    public weak var previousViewController: BluetoothPeripheralViewController?
    
    private func beforeExit() {
        guard let vc = previousViewController else { return }
        vc.connectButtonHandler(false)
        vc.connectButtonHandler(false)
    }
    
    //MARK: - TableView Method
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 38 : 120
    }

    
    //MARK: Interactions
    
    @IBAction func update(sender: UIButton) {
        run()
    }
    
    private func prepare() {
        runQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            do {
                if self.manager.selected?.peripheral?.isConnected == true {
                    try self.manager.selected?.prepare()
                } else {
                    try self.manager.selected?.teardown()
                }
            } catch {
                //ignore
            }
        }
    }
    
    private func magicConnect() {
        runQueue.async {[weak self] in
            guard let `self` = self else { return }
            
            do {
                if (self.manager.selected?.peripheral?.isConnected)! {
                    try self.manager.selected?.teardown()
                } else {
                    try self.manager.selected?.connectThenDisconnect()
                }
            } catch {
                //ignore
            }
        }
    }
    
    private func connect() {
        runQueue.async { [weak self] in
            guard let `self` = self else { return }
            do {
                if (self.manager.selected?.peripheral?.isConnected)! {
                    try self.manager.selected?.teardown()
                } else {
                    try self.manager.selected?.establish()
                }
            } catch {
                //ignore
            }
        }
    }
    
    
    //MARK: PeripheralDelegate
    func peripheral(_ peripheral: PeripheralBase, didChangeState oldState: PeripheralState, newState: PeripheralState) {
        DispatchQueue.main.async { [weak self] in
            //            print("-- DispatchQueue.main.async: Peripheral state changed")
            print("BleDeviceViewController: \(newState.description)")
            self?.updateButtons()
            self?.updateLabels()
        }
    }
    
    
    //MARK: Event
    func onStateChanged(args: StateChangedEventArgs) {
        DispatchQueue.main.async { [weak self] in
            //            print("-- DispatchQueue.main.async: Update buttons and labels on state change")
            print("BleDeviceViewController: \(args.newState)")
            self?.updateButtons()
            self?.updateLabels()
            self?.updateNavigationBar()
                                    
            self?.stateLabel.text = self?.manager.selected?.state.description ?? "-"
        }
    }
    
    func updateNavigationBar()
    {
        if  manager.selected?.state == PeripheralState.idle
        {
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            backEnabledButton()
        }
        
        if  manager.selected?.state == PeripheralState.update || manager.selected?.state == PeripheralState.establishLink
        {
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            backDisabledButton()
        }
    }
    
    func onProgress(args: FotaProgressEventArgs)
    {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            if args.current == 0
            {
                self.currentStep = args.step
                
                var text = self.currentStep.description
                if self.currentStep == .finished {
                    text = text + ", waiting..."
                }
                self.progressLabel.text = text
            }
            
            if args.total == 0
            {
                self.progressBar.progress = 0
                self.currentProgress = 0;
            }
            else
            {
                self.progressLock.sync {
                    self.currentProgress = args.current
                }
                
                let progress: Float = Float(args.current) / Float(args.total)
                print(progress)
                self.progressBar.progress = CGFloat(progress)
            }
        }
    }
    
    func onCompleted(args: FotaCompletedEventArgs)
    {
        DispatchQueue.main.async { [weak self] in
            print("Update finnished. Fota: \(args.status.description)")
            self?.progressLabel.text = "code: \(args.status.description), reconnecting..."
        }
        self.throughputTimer?.invalidate()
        self.throughputTimer = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [weak self] in
            self?.magicConnect()
            self?.progressLabel.text = "exit in 5s..."
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: Functions
    func updateButtons()
    {
        var enabled = false
        guard manager.selected != nil else{
            setButtonsEnabled(false)
            return
        }
        
        if  manager.selected?.state == PeripheralState.ready {
            enabled = true
        }
        
        setButtonsEnabled(enabled)
    }
    
    func updateLabels() {
        stateLabel.text = manager.selected?.state.description
    }
    
    //MARK: Private functions
    private func backEnabledButton(){
        let backBarButton = UIBarButtonItem(withCustomType: .backButton,
                                            target: self,
                                            action: #selector(BleDeviceViewController.backButtonAction))
        self.navigationItem.leftBarButtonItem = backBarButton
        self.navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    private func backDisabledButton(){
        let backBarButton = UIBarButtonItem(withCustomType: .backDisabledButton,
                                            target: self,
                                            action: #selector(BleDeviceViewController.backButtonAction))
        self.navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    private func setButtonsEnabled(_ enabled: Bool)
    {
        updateButton.isEnabled = enabled
    }
    
    private func initButtons()
    {
        updateButton.setTitleColor(UIColor.gray, for: UIControl.State.disabled)
    }
    
    private func run()
    {
        
        guard manager.selected != nil else
        {
            return
        }
        
        runQueue.async{ [weak self] in
            guard let `self` = self else { return }
            
            self.currentProgress = 0
            self.lastProgress = 0
            self.throughput = 0
            
            
            self.controller = FotaController()
            
            var options = FotaOptions()
            options.forceUpdate = false
            
            self._progressHandler = self.controller?.eventProgress.addHandler(self, BleDeviceViewController.onProgress)
            self._completedHandler = self.controller?.eventCompleted.addHandler(self, BleDeviceViewController.onCompleted)
            let setup = UpdateSetup(provider: self.controller!, source: self.fotaFile ,options: options)
            
            DispatchQueue.main.async {
                self.throughputTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onProgressTimerElapsed(timer:)), userInfo: nil, repeats: true)
            }
            
            do
            {
                try self.manager.selected?.update(updateSetup: setup)
            }
            catch
            {
                self.log.error("Update failed: \(error)")
            }
            
            self._progressHandler?.dispose()
            self._completedHandler?.dispose()
            
            if self.manager.selected!.state != PeripheralState.idle
            {
                do{
                    try self.manager.selected?.teardown()
                }
                catch
                {
                    self.log.error("Teardown faild")
                }
            }
        }
    }
    
    private func registerDeviceEvents()
    {
        _stateChangedHandler = manager.selected?.eventStateChanged.addHandler(self, BleDeviceViewController.onStateChanged)
    }
    
    private func deregisterDeviceEvents()
    {
        _stateChangedHandler?.dispose()
    }
    
    @objc private func onProgressTimerElapsed(timer: Timer)
    {
        progressLock.sync
            {
                if (currentStep == FotaUpdateStep.updateFotaImage || currentStep == FotaUpdateStep.updateAppImage)
                {
                    let progress = currentProgress! - lastProgress!
                    lastProgress = currentProgress!
                    if currentProgress == 0
                    {
                        throughput = 0
                        return
                    }
                    
                    throughput = Double(progress) / 1024
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        self.progressLabel.text = "\(self.currentStep.description) - \(String(format: "%.2f", self.throughput))kB/s"
                        
                    }
                }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var i = 0;
        
    }
        
    override func viewWillDisappear(_ animated: Bool)
    {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            
            do
            {
                if (self.manager.selected?.state == PeripheralState.ready)
                {
                    try self.manager.selected?.teardown()
                }
            }
            catch
            {

            }
        }
        deregisterEvents()
    }
    
    private func compare(version1: String, greaterThan version2: String) -> Bool {
        let v1 = (version1 + ".0.0").prefix(5)
        let v2 = (version2 + ".0.0").prefix(5)
        return v1.compare(v2, options: .numeric) == .orderedDescending
    }
}


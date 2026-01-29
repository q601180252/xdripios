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
    
    var manager: FotaPeripheralManager = FotaPeripheralManager(true)
    var fotaFile: FotaFile?
    
    //MARK: eventhandlers
    private var _stateChangedHandler: EventHandlerProtocol?
    private var _progressHandler: EventHandlerProtocol?
    private var _completedHandler: EventHandlerProtocol?
    

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var bootloaderLabel: UILabel!
    @IBOutlet weak var fotaLabel: UILabel!
    @IBOutlet weak var deviceAppLabel: UILabel!
    @IBOutlet weak var fileFotaLabel: UILabel!
    @IBOutlet weak var fileAppLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var selectFileButton: UIButton!
    
    @IBOutlet weak var progressBar: CircularProgressView!
    @IBOutlet weak var updateButton: RoundButton!
        
    private var progressView: UIProgressView!

    //MARK: members
    private var throughputTimer: Timer? = nil
    private var controller: FotaController?
    private var currentProgress: Int? = 0
    private var lastProgress: Int? = nil
    private var currentStep: FotaUpdateStep = FotaUpdateStep.idle
    private var progressLock = DispatchQueue(label: "com.onsemi.fota.BleDeviceViewController.progressLock", attributes:  .concurrent)
    private var runQueue = DispatchQueue(label: "fota.RunQueue")
    private var throughput: Double = 0.0
    private let log: LogProtocol = LogManager.manager.createLog(name: "BleDeviceViewController")
    private var whiteColor: UIColor = UIColor.blue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateLabel.text = manager.selected?.state.description
        nameLabel.text = manager.selected?.name
        addressLabel.text = manager.selected?.uuid.uuidString
        progressBar.progress = 0
        
        whiteColor = self.navigationController?.navigationBar.tintColor ?? UIColor.white
        
        initButtons()
        tableView.separatorStyle = .none
        
        fotaFile = FotaFile(filePath: "")
        
        fileFotaLabel.text = fotaFile?.fotaImage.version.imageVersion
        fileAppLabel.text = fotaFile?.AppImage.version.imageVersion
        
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .modena
        
        progressView = UIProgressView()
        
        progressView.progressTintColor = .pinkRed
        progressView.trackTintColor = .grayProgress
        progressView.progressViewStyle = .bar

        self.view.backgroundColor = .modena
        self.view.addSubview(view)
                
        view.addSubview(progressView)
        progressView.progress = 0
                
        let label = UILabel()
        label.text = TextsSetting.upgrade
        label.textColor = .white
        label.font = .systemFont(ofSize: 34)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(100)
            make.centerX.equalToSuperview()
        }
        
        let aLabel = UILabel()
        aLabel.text = TextsSetting.upgrade
        aLabel.textColor = .white
        aLabel.font = .systemFont(ofSize: 14)
        view.addSubview(aLabel)
        aLabel.text = UserDefaultsUnit.mac ?? ""
        aLabel.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }

        
        progressView.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(aLabel.snp.bottom).offset(14)
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startOTA()
    }
    
    deinit {
        print("deinit - BLEDeviceViewController")
    }
    
    
    func onBleListChanged(args: EmptyEventArgs)
    {
        let uuidString = AppDelegate.cgmTransmitter?.peripheral?.peripheral?.identifier.uuidString
        manager.selected = manager.peripherals.filter({ $0.peripheral?.uuid.uuidString == uuidString }).first
        
        print(manager.peripherals.map({$0.name}))
        if manager.selected != nil {
            manager.stopScan()
            registerEvents()
        } else {
            manager.stopScan()
            manager.startScan()
        }
    }

    private var _bleProducListChangedHandler: EventHandlerProtocol?

    private func startOTA() {
        AppDelegate.cgmTransmitter?.startOTA()
        
//        bPeripheral = AppDelegate.cgmTransmitter?.peripheral
//        AppDelegate.cgmTransmitter?.disconnectCurrent()
        
        manager.stopScan()
        manager.startScan()
        
        _bleProducListChangedHandler = manager.eventBleProductListChanged.addHandler(self, BleDeviceViewController.onBleListChanged)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) { [weak self] in self?.connect() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backEnabledButton()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        try? manager.selected?.teardown()
        try? manager.selected?.peripheral?.disconnect(timeout: 3)
                
        _bleProducListChangedHandler?.dispose()
        
        AppDelegate.cgmTransmitter?.disconnectCurrent()
        AppDelegate.cgmTransmitter?.scan()
    }
    
    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TableView Method
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = #colorLiteral(red: 0.1723527014, green: 0.4339691997, blue: 0.6401203275, alpha: 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1 {
            return 135
        }else{
            return UITableView.automaticDimension
        }
    }

    
    private func connect() {
        runQueue.async {
            do
            {
                if (self.manager.selected != nil) {
                    if (self.manager.selected?.peripheral?.isConnected)!
                    {
                        try self.manager.selected?.teardown()
                    }
                    else
                    {
                        try self.manager.selected?.establish()
                    }

                }
            }
            catch
            {
                //ignore
            }
        }
    }
    
    //MARK: Interactions
    
    @IBAction func connect(_ sender: UIButton) {
        connect()
    }
    
    
    @IBAction func update(_ sender: RoundButton) {
        run()
    }
    
    //MARK: PeripheralDelegate
    func peripheral(_ peripheral: PeripheralBase, didChangeState oldState: PeripheralState, newState: PeripheralState) {
        DispatchQueue.main.async {
            //            print("-- DispatchQueue.main.async: Peripheral state changed")
            print("BleDeviceViewController: \(newState.description)")
            self.updateButtons()
            self.updateLabels()
        }
    }
    
    //MARK: Event
    func onStateChanged(args: StateChangedEventArgs)
    {
        DispatchQueue.main.async {
            //            print("-- DispatchQueue.main.async: Update buttons and labels on state change")
            print("BleDeviceViewController: \(args.newState)")
            self.updateButtons()
            self.updateLabels()
            self.updateNavigationBar()
            
            if self.manager.selected?.state == PeripheralState.ready {
                self.run()
            }
        }
    }
    
    func updateNavigationBar()
    {
        if  manager.selected?.state == PeripheralState.idle
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            backEnabledButton()
        }
        
        if  manager.selected?.state == PeripheralState.update || manager.selected?.state == PeripheralState.establishLink
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true;
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            backDisabledButton()
        }
    }
    
    func onProgress(args: FotaProgressEventArgs)
    {
        DispatchQueue.main.async {
            if args.current == 0
            {
                self.currentStep = args.step
                self.progressLabel.text = self.currentStep.description
            }
            
            if args.total == 0
            {
                self.progressBar.progress = 0
                self.progressView.progress = 0
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
                self.progressView.progress = progress
            }
        }
    }
    
    func onCompleted(args: FotaCompletedEventArgs)
    {
        DispatchQueue.main.async
            {
                print("Update finnished. Fota: \(args.status.description)")
                self.progressLabel.text = "update finished with code: \(args.status.description)"
                
                self.navigationController?.popToRootViewController(animated: true)
        }
        self.throughputTimer?.invalidate()
        self.throughputTimer = nil
    }
    
    //MARK: Functions
    func updateButtons()
    {
        var enabled = false
        guard manager.selected != nil else{
            setButtonsEnabled(false)
            return
        }
        
        if  manager.selected?.state == PeripheralState.idle{
            enabled = true
            connectButton.setTitle("CONNECT", for: UIControl.State.normal)
        }
        
        if  manager.selected?.state == PeripheralState.ready{
            enabled = true
            connectButton.setTitle("DISCONNECT", for: UIControl.State.normal)
        }
        
        setButtonsEnabled(enabled)
    }
    
    func updateLabels()
    {
        stateLabel.text = manager.selected?.state.description
        
        if manager.selected != nil {
            
            if(manager.selected!.bootloaderVersion) != nil && manager.selected?.state != PeripheralState.idle
            {
                bootloaderLabel.text = manager.selected?.bootloaderVersion?.description
            }
            else
            {
                bootloaderLabel.text = "-"
            }
            
            if (manager.selected!.bleStackVersion) != nil && manager.selected?.state != PeripheralState.idle
            {
                fotaLabel.text = manager.selected?.bleStackVersion?.description
            }
            else
            {
                fotaLabel.text = "-"
            }
            
            if(manager.selected!.applicationVersion) != nil && manager.selected?.state != PeripheralState.idle
            {
                deviceAppLabel.text = manager.selected?.applicationVersion?.description
            }
            else
            {
                deviceAppLabel.text = "-"
            }
        }
    }
    
    //MARK: Private functions
    private func backEnabledButton(){
        let backBarButton = UIBarButtonItem(withCustomType: .backButton,
                                            target: self,
                                            action: #selector(BleDeviceViewController.backButtonAction))
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    private func backDisabledButton(){
        let backBarButton = UIBarButtonItem(withCustomType: .backDisabledButton,
                                            target: self,
                                            action: #selector(BleDeviceViewController.backButtonAction))
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    private func setButtonsEnabled(_ enabled: Bool)
    {
        connectButton.isEnabled = enabled
        selectFileButton.isEnabled = enabled
        updateButton.isEnabled = enabled
    }
    
    private func initButtons()
    {
        connectButton.setTitleColor(UIColor.gray, for: UIControl.State.disabled)
        selectFileButton.setTitleColor(UIColor.gray, for: UIControl.State.disabled)
        updateButton.setTitleColor(UIColor.gray, for: UIControl.State.disabled)
    }
    
    private func run()
    {
        
        guard manager.selected != nil else
        {
            return
        }
        
        guard fotaFile != nil else
        {
            progressLabel.text = "Error: No file selected!"
            return
        }
        
        
        runQueue.async{
            
            self.currentProgress = 0
            self.lastProgress = 0
            self.throughput = 0
            
            
            self.controller = FotaController()
            
            var options = FotaOptions()
            options.forceUpdate = false
            
            self._progressHandler = self.controller?.eventProgress.addHandler(self, BleDeviceViewController.onProgress)
            self._completedHandler = self.controller?.eventCompleted.addHandler(self, BleDeviceViewController.onCompleted)
            let setup = UpdateSetup(provider: self.controller!, source: self.fotaFile ,options: options)
            
            DispatchQueue.main.async{
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
    
    private func registerEvents()
    {
        _stateChangedHandler = manager.selected?.eventStateChanged.addHandler(self, BleDeviceViewController.onStateChanged)
    }
    
    private func deregisterEvents()
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
                    
                    DispatchQueue.main.async {
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
                DispatchQueue.global(qos: .background).async {
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
}

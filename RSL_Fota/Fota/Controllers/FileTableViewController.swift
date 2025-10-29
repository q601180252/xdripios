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
 * Class Name: FileTableViewController.swift
 */

import FotaLibrary
import UIKit
import Foundation
class FileTableViewController: UITableViewController, UIDocumentPickerDelegate {
    
    var files = [String]()
    
    var fotaFile: FotaFile?
    
    //Table view cells are reused and should be dequeued using a cell identifier
    let cellIdentifier = "FileTableViewCell"
    
    override func viewWillAppear(_ animated: Bool) {
        backButton()
        
        if files.isEmpty
        {
            let alert = UIAlertController(title: "Warning", message: "No fota file found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                case .cancel:
                    //Do nothing
                    break;
                case .destructive:
                    //Do nothing
                    break;
                }}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 65.0
        fotaFile = nil;
        do {
            if inboxDirCopy(){
                print("Copied Files from Inbox directory")
            }
            var documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            documentsURL.appendPathComponent("fota")
            let docs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [], options:  [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            let fotaFiles = docs.filter{ $0.pathExtension == "fota" }
            
            for url in fotaFiles
            {
                files.append(url.pathComponents.last!)
            }
            print("FileTableViewController:  \(files)")
        } catch {
            print(error)
        }
    }
    
    //MARK: Document Picker Helper Methods
    
    func reloadData(){
        files.removeAll()
        tableView.reloadData()
        do{
            var documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            documentsURL.appendPathComponent("fota")
            let docs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [], options:  [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            let fotaFiles = docs.filter{ $0.pathExtension == "fota" }
            
            for url in fotaFiles
            {
                files.append(url.pathComponents.last!)
            }
            tableView.reloadData()
        }
        catch{
            print(error)
        }
    }
    
    private func documentDir() throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    private func dfuDir() throws -> URL {
        let dfuDir = try documentDir().appendingPathComponent("fota")
        var isDir : ObjCBool = false
        if !FileManager.default.fileExists(atPath: dfuDir.path, isDirectory: &isDir) {
            try FileManager.default.createDirectory(atPath: dfuDir.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        return dfuDir
    }
    
    private func inboxDirCopy()-> Bool{
        do{
            var inboxURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            inboxURL.appendPathComponent("Inbox")
            let docs = try FileManager.default.contentsOfDirectory(at: inboxURL, includingPropertiesForKeys: [], options:  [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            let fotaFiles = docs.filter{ $0.pathExtension == "fota" }
            
            for url in fotaFiles
            {
                guard let newUrl = try? dfuDir().appendingPathComponent(url.lastPathComponent) else {
                        return false
                }
                var isDir : ObjCBool = false
                if FileManager.default.fileExists(atPath: newUrl.path, isDirectory: &isDir) {
                    try FileManager.default.removeItem(at: url)
                    print("item deleted")
                }else{
                    try FileManager.default.moveItem(at: url, to: newUrl)
                }
            }
        }catch{
            print(error)
        }
        return true
    }
    
    func handleUrl(_ url: URL) -> Bool {
        guard url.isFileURL,
            url.pathExtension == "fota",
            let newUrl = try? dfuDir().appendingPathComponent(url.lastPathComponent) else {
                return false
        }
        
        do {
            try FileManager.default.moveItem(at: url, to: newUrl)
        } catch let error {
            print(error)
            return false
        }
        files.append(newUrl.pathComponents.last!)
        tableView.reloadData()
        return true
    }
    
    func openDocumentPicker(presentOn controller: UIViewController) {
        let documentPickerVC = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        documentPickerVC.delegate = self
        if #available(iOS 13.0, *) {
            documentPickerVC.isModalInPresentation = true
        } else {
            documentPickerVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        }
        controller.present(documentPickerVC, animated: true)
    }

    //MARK: Document Picker Delegate Methods
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if handleUrl(url){
            print("Document Imported")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        reloadData()
    }
    
    //MARK: Document Picker Navigation
    
    @IBAction func openDocumentPicker(_ sender: UIBarButtonItem) {
        openDocumentPicker(presentOn: self)
    }
    
    //MARK: Navigate to BleDeviceViewController
    
    private func backButton(){
        let backBarButton = UIBarButtonItem(withCustomType: .backButton,
                                            target: self,
                                            action: #selector(BleDeviceViewController.backButtonAction))
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return files.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FileTableViewCell else
        {
            fatalError("The dequeued cell is not an instance of FileTableViewCell")
        }
        
        let fileName = files[indexPath.row]
        
        cell.fileNameLabel.text = fileName
        cell.backgroundColor = #colorLiteral(red: 0.420782268, green: 0.5364181399, blue: 0.5781204104, alpha: 1).darker(componentDelta: CGFloat(indexPath.row)/CGFloat(files.count))
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    
   @available(iOS 11.0, *)
   override func tableView(_ tableView: UITableView,trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Write action code for the trash
        let TrashAction = UIContextualAction(style: .normal, title:  "Trash", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let fileName = self.files[indexPath.row]
            do{
                if let deleteUrl = try? self.dfuDir().appendingPathComponent(fileName){
                    try FileManager.default.removeItem(at: deleteUrl)
                    self.files.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }catch{
                print(error)
            }
        })
        TrashAction.image = UIImage(named: "trash-icon")
        TrashAction.backgroundColor = .red

        return UISwipeActionsConfiguration(actions: [TrashAction])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Trash"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fileName = self.files[indexPath.row]
            do{
                if let deleteUrl = try? self.dfuDir().appendingPathComponent(fileName){
                    try FileManager.default.removeItem(at: deleteUrl)
                    self.files.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }catch{
                print(error)
            }
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        guard let selectedFileCell = sender as? FileTableViewCell
            else{
                fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedFileCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedFile = files[indexPath.row]
        
        fotaFile = FotaFile(fileName: selectedFile)
    }
}

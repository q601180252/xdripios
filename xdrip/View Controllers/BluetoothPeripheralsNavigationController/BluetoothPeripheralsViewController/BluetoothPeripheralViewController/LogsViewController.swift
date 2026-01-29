//
//  LogsViewController.swift
//  DiaBox
//
//  Created by Dongdong Gao on 11/26/24.
//  Copyright © 2024 Johan Degraeve. All rights reserved.
//

import UIKit

enum CellState {
    case open
    case close
}

class LogsViewController: UITableViewController {
    
    private var data: [LogsBubbleItem] = []
    
    var coreDataManager: CoreDataManager? {
        didSet {
            if let c = coreDataManager {
                logsBubbleAccessor = LogsBubbleAccessor(coreDataManager: c)
            }
        }
    }
    
    private var logsBubbleAccessor: LogsBubbleAccessor?
    
    private var currentOpen: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Logs"
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(back))
        backButton.tintColor = .systemBlue
        self.navigationItem.leftBarButtonItem = backButton
        
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clear))
        rightBarButtonItem.tintColor = .red
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
                
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func clear() {
        logsBubbleAccessor?.clear()
        loadData()
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if indexPath.row == 0 {
            let detailCell = (tableView.dequeueReusableCell(withIdentifier: "DetailCell") as? DetailCell) ?? DetailCell(style: .default, reuseIdentifier: "DetailCell")
            let detail = data[indexPath.section]
            detailCell.update(detail.logs, showCurrent: indexPath.section == 0 && indexPath.row == 0)
            
            cell = detailCell
        } else {
            let summaryCell = (tableView.dequeueReusableCell(withIdentifier: "SummaryCell") as? SummaryCell) ?? SummaryCell(style: .default, reuseIdentifier: "SummaryCell")
            let summary = data[indexPath.section].list[indexPath.row - 1]
            summaryCell.update(summary)
            
            cell = summaryCell
        }
                
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentOpen == section ? (data[section].list.count + 1) : 1
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let lastOpen = currentOpen
        currentOpen = indexPath.section == lastOpen ? -1 : indexPath.section
        
//        UIView.animate(withDuration: 0.3) {
            if lastOpen != -1 {
                tableView.reloadSections([lastOpen, indexPath.section], with: .automatic)
            } else {
                tableView.reloadSections([indexPath.section], with: .automatic)
            }
//        }
    }
    
    private func loadData() {
        defer {
            tableView.reloadData()
        }

        guard let list = logsBubbleAccessor?.findBattery100All2() else {
            data = []
            return
        }

        data = list
    }
}

extension Optional<Date> {
    var display: String {
        guard let d = self else { return "-" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: d)
    }
}

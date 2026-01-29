//
//  NanoOTAFetcher.swift
//  xdrip
//
//  Created by Dongdong Gao on 11/13/24.
//  Copyright © 2024 Johan Degraeve. All rights reserved.
//

import FotaLibrary

public struct NanoFirmwareInfo {
    let content: String
    let versionCode: String
    let createTime: String
    let osType: String
    let url: String
    let id: String
}

public class NanoOTAFetcher {
    
    func display(_ local: String?) -> String? {
        if hasNewVersion(local) {
            return "New Version Found"
        }
        
        return local
    }
    
    private(set) var latestFotaFile: FotaFile?
    
    func hasNewVersion(_ local: String?) -> Bool {
        guard let latestVersion = latestVersion else { return false }
        guard let localVersion = local else { return false }
        
        return compare(version1: latestVersion, greaterThan: localVersion)
    }
    
    var latestVersion: String? {
        latestFotaFile?.AppImage.version.imageVersion
    }
    
    init() {
        loadLocalFotaFile()
        nanoFetchLatest()
    }
    
    private func nanoFetchLatest() {
        let parameters = "{\"OS\":\"BubbleNano\"}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://www.glucose.space/api/updateApp")!)
        request.addValue("bubble-201907", forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let dataContent = json["data"] as? [String: Any] {
                        
                        if let url = dataContent["url"] as? String,
                           let versionCode = dataContent["versionCode"] as? Int {
                            // print("URL: \(url)")
                            // print("Version Code: \(versionCode)")

                            self?.downloadFile(from: url)
                        } else {
                            // print("Error: Could not find 'url' or 'versionCode'")
                        }
                    } else {
                        // print("Error: Could not find 'data' field in JSON")
                    }
                }
            } catch {
                // print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
    private func downloadFile(from urlString: String) {
        guard let url = URL(string: urlString) else {
            // print("Invalid URL string.")
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { [weak self] tempLocalUrl, response, error in
            if let error = error {
                // print("Download failed with error: \(error.localizedDescription)")
                return
            }
            
            guard let tempLocalUrl = tempLocalUrl, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                // print("Failed to download or invalid response.")
                return
            }
            
            self?.copyFileToDocumentsDirectory(from: tempLocalUrl)
        }
        
        task.resume()
    }
    
    private func copyFileToDocumentsDirectory(from sourceURL: URL) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationURL = documentsDirectory.appendingPathComponent("target.fota")
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            // print("File already exists at destination")
            try? FileManager.default.removeItem(atPath: destinationURL.path)
        }
        
        do {
            // 复制文件到 Documents 目录
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            // print("File copied to: \(destinationURL)")
            
            loadLocalFotaFile()
        } catch {
            // print("Failed to copy file: \(error)")
        }
    }
    
    private func loadLocalFotaFile() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent("target.fota")

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            latestFotaFile = FotaFile(filePath: destinationURL.path)
            return
        }
        
        if let bundleFilePath = Bundle.main.path(forResource: "s8.1_h1.5_20240919", ofType: "fota") {
            latestFotaFile = FotaFile(filePath: bundleFilePath)
            return
        }
    }
    
    private func compare(version1: String, greaterThan version2: String) -> Bool {
        let v1 = (version1 + ".0.0").prefix(5)
        let v2 = (version2 + ".0.0").prefix(5)
        return v1.compare(v2, options: .numeric) == .orderedDescending
    }
}

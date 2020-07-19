//
//  DevicesManager.swift
//  QuickSimulator
//
//  Created by zkhCreator on 2020/7/19.
//  Copyright © 2020 zkhCreator. All rights reserved.
//

import Cocoa

class DevicesManager: NSObject {
    static let shared = DevicesManager()
    
    private let xcrunTask = Process()
    private let outputPipe = Pipe()
    private let errorOutput = Pipe()
    
    private let decoder = JSONDecoder()
    
    var deviceList:[Device] = []

    override init() {
        super.init()
        deviceList = loadDvices()
        print(deviceList.map{print($0.osVersion)})
    }
    
    func loadDvices() -> [Device] {
        xcrunTask.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        xcrunTask.arguments = ["simctl", "list", "-j", "devices"]
        xcrunTask.standardOutput = outputPipe
        
        do {
            try xcrunTask.run()
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            return convertDataToDevices(data: data)
        } catch let e {
            Logger.e(message: e.localizedDescription)
            return []
        }
    }
    
    func convertDataToDevices(data: Data) -> [Device] {
        do {
            let info = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let deviceInfo = info as? [String: [String: [[String: Any]]]],
                let deviceCategory = deviceInfo["devices"] else {
                return []
            }

            let deviceArray = deviceCategory.map {(key, value) -> [Device] in
                let system = self.systemString(with: key)
                print(system)
                guard let devices = try? self.convertToDevice(system: system, categoryInfo: value) else {
                    return []
                }
                return devices
            }

            return deviceArray.flatMap {$0}
        } catch let e {
            Logger.e(message: e.localizedDescription)
            return []
        }
    }
    
    private func systemString(with key:String) -> String {
        return key.replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
    }
    
    private func convertToDevice(system:String, categoryInfo: [[String: Any]]) throws -> [Device] {
        return try categoryInfo.map { (itemInfo) -> Device in
            let device = try decoder.decode(Device.self, from: JSONSerialization.data(withJSONObject: itemInfo, options: .fragmentsAllowed))
            device.system = system
            return device
        }
    }
}

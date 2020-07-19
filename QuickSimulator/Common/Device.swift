//
//  Device.swift
//  QuickSimulator
//
//  Created by zkhCreator on 2020/7/19.
//  Copyright © 2020 zkhCreator. All rights reserved.
//

import Cocoa

class Device: NSObject, Codable {

    enum State: String, Codable {
        case Shutdown, Creating, Invaild
    }
    
    enum OS: String, Codable {
        case tvOS, watchOS, iOS, UnKnowed
    }
    
    var dataPath:String
    var logPath:String
    var udid:String
    var isAvailable:Bool
    var deviceTypeIdentifier:String
    var state:State
    var name:String
    var os:OS?
    var osVersion:String?
    var system:String? {
        set {
            var osList = newValue?.split(separator: "-")
            let os = String(osList?.removeFirst() ?? "UnKnowed")
            self.os = OS(rawValue: os) ?? .UnKnowed
            self.osVersion = osList?.joined(separator: ".") ?? ""
        }
        get {
            return self.os?.rawValue
        }
    }
}

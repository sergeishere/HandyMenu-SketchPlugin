//
//  HMDataLoader.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 14/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation

public class PluginDataCaretaker {
    
    // MARK : - Handling keys
    private let suiteName = "com.sergeishere.plugins.handymenu"
    
    // MARK: - Handling Versions
    public enum DataVersion: String {
        case legacy = "plugin_sketch_handymenu_my_commands"
        case v4 = "plugin_sketch_handymenu_user_commands"
        case v5 = "plugin_sketch_handymenu_data"
        
        public func key() -> String {
            return self.rawValue
        }
    }
    
    // MARK: - Instance Properties
    private var userDefaults: UserDefaults
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init() {
        userDefaults = UserDefaults(suiteName: suiteName)!
    }
    
    public func retrieve() -> PluginData {
        if let encodedData = userDefaults.data(forKey: DataVersion.v5.key()),
            let data = try? decoder.decode(PluginData.self, from: encodedData) {
            return data
        } else if let encodedData = userDefaults.data(forKey: DataVersion.v4.key()) {
            //        guard let data = userDefaults?.object(forKey: Keys.userCommands) as? Data,
            //            let objects = NSKeyedUnarchiver.unarchiveObject(with: data)
            //            else { return }
            //        let commandsData = UserDefaults.standard.string(forKey: Keys.oldUserCommands)!.removingPercentEncoding?.data(using: .utf8)
            //        let commandsString = try! JSONSerialization.jsonObject(with: commandsData!, options: .mutableContainers)
            //        NSLog("[Handy Menu] %@", String(describing: commandsString))
        }
        return PluginData()
    }
}

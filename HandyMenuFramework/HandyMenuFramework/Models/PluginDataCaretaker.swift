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
    
    public func retrieve() -> PluginData? {
        if let encodedData = userDefaults.data(forKey: DataVersion.v5.key()),
            let data = try? decoder.decode(PluginData.self, from: encodedData) {
            return data
        } else if let encodedData = userDefaults.data(forKey: DataVersion.v4.key()),
            let objects = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? [HMCommandScheme] {
            var newItems: [MenuItemData] = []
            for object in objects {
                let newItemData = PluginCommandData(name: object.name, commandID: object.commandID, pluginID: object.pluginID)
                newItems.append(.command(newItemData))
            }
            let shortcut = Shortcut(commandIsPressed: true, optionIsPressed: false, controlIsPressed: false, shiftIsPressed: false, keyCode: 21)
            var newData = PluginData()
            newData.collections.append(MenuData(title: "Main", shortcut: shortcut, items: newItems, manualGrouping: false))
            return newData
        }
        return nil
    }
    
}

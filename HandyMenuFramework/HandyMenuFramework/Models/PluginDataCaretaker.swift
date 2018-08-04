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
    
    private let v4key = "plugin_sketch_handymenu_user_commands"
    private let v5key = "plugin_sketch_handymenu_data"
    
    // MARK: - Instance Properties
    private var userDefaults: UserDefaults
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public enum RetrievingResult {
        case v4([HMCommandScheme])
        case v5(PluginData)
        case empty
    }
    
    public init() {
        userDefaults = UserDefaults(suiteName: suiteName)!
    }
    
    public func retrieve() -> RetrievingResult {
        if let encodedData = userDefaults.data(forKey: v5key),
            let data = try? decoder.decode(PluginData.self, from: encodedData) {
            return RetrievingResult.v5(data)
        } else if let encodedData = userDefaults.data(forKey: v4key),
            let objects = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? [HMCommandScheme] {
            return RetrievingResult.v4(objects)
        }
        return RetrievingResult.empty
    }
    
}

//
//  HMPluginData.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 14/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public struct PluginData: Codable {
    public var userID: UUID
    public var pluginVersion:Double
    public var collections: [Collection]
    
    static public var currentVersion: Double = 5.2
}

extension PluginData {
    public static var empty: PluginData {
        return PluginData(
            userID: UUID(),
            pluginVersion: PluginData.currentVersion,
            collections: [.emptyCollection])
    }
}

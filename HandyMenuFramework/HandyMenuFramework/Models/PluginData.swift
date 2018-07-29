//
//  HMPluginData.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 14/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation

public struct PluginData: Codable {
    public var userID: UUID
    public var pluginVersion:Double
    public var collections: [MenuData]
    
}

extension PluginData {
    public static var empty: PluginData {
        return PluginData(userID: UUID(), pluginVersion: 5.0, collections: [.emptyCollection])
    }
}

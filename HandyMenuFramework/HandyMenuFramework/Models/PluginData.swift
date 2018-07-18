//
//  HMPluginData.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 14/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation

public struct PluginData: Codable {
    
    public var userID: UUID = UUID()
    public var pluginVersion:Double = 5.0
    public var collections: [MenuData] = []
    
}

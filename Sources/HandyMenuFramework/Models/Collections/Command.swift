//
//  PluginCommandData.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public struct Command:Codable, Equatable {
    public var name:String
    public var commandID:String
    public var pluginName: String
    public var pluginID:String
}

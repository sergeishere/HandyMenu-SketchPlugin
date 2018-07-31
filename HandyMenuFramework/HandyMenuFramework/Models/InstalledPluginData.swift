//
//  InstalledPluginData.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 27/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation

public struct InstalledPluginData: Equatable {
    public var title: String
    public var commands: [PluginCommandData]
}

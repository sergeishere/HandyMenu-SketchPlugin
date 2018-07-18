//
//  MenuGroup.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public struct MenuData:Codable {
    public var items:[MenuItemData]
    public var shortcut: Shortcut
    public var manualGrouping: Bool = false
}

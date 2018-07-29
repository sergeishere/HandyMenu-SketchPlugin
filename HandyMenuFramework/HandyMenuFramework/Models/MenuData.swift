//
//  MenuGroup.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public struct MenuData:Codable {
    public var title: String
    public var shortcut: Shortcut
    public var items:[MenuItemData]
    public var manualGrouping: Bool
}

extension MenuData {
    public static var emptyCollection:MenuData {
        return MenuData(title: "New Collection", shortcut: .empty, items: [], manualGrouping: false)
    }
}

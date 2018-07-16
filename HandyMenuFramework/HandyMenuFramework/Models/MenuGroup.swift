//
//  MenuGroup.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public struct MenuGroup:Codable {
    public var menuElements:[MenuElement]
    public var shortcut: Shortcut
}

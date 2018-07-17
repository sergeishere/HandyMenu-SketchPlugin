//
//  Shortcut.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public struct Shortcut: Codable, Hashable {
    public var commandIsPressed: Bool
    public var optionIsPressed: Bool
    public var controlIsPressed: Bool
    public var shiftIsPressed: Bool
    public var keyCode: Int
}

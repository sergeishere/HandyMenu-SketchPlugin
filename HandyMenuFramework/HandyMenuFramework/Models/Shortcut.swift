//
//  Shortcut.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public struct Shortcut: Codable, Hashable {
    public var commandIsPressed: Bool = false
    public var optionIsPressed: Bool = false
    public var controlIsPressed: Bool = false
    public var shiftIsPressed: Bool = false
    public var keyCode: Int = 0
}

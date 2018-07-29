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
    public var character: String = ""
    
    public var stringRepresentation: String {
        get {
            var s = ""
            s.append(self.controlIsPressed ? "⌃" : "")
            s.append(self.optionIsPressed ? "⌥" : "")
            s.append(self.shiftIsPressed ? "⇧" : "")
            s.append(self.commandIsPressed ? "⌘" : "")
            s.append(self.character)
            return s
        }
    }
}

extension Shortcut {
    public static var empty: Shortcut {
        return Shortcut(commandIsPressed: false, optionIsPressed: false, controlIsPressed: false, shiftIsPressed: false, keyCode: 0, character: "")
    }
}

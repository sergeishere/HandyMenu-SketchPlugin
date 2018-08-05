//
//  Shortcut.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public struct Shortcut: Codable, Hashable {
    public var keyCode: Int = 0
    public var modifierFlags: Shortcut.ModifierFlags
    public var character: String = ""
    
    public var stringRepresentation: String {
        get {
            var representation = ""
            representation.append(self.modifierFlags.contains(.control) ? "⌃" : "")
            representation.append(self.modifierFlags.contains(.option) ? "⌥" : "")
            representation.append(self.modifierFlags.contains(.shift) ? "⇧" : "")
            representation.append(self.modifierFlags.contains(.command) ? "⌘" : "")
            representation.append(self.character)
            return representation
        }
    }
    
    public struct ModifierFlags: OptionSet, Codable, Hashable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static var control = ModifierFlags(rawValue: 1 << 0)
        public static var option = ModifierFlags(rawValue: 1 << 1)
        public static var shift = ModifierFlags(rawValue: 1 << 2)
        public static var command = ModifierFlags(rawValue: 1 << 3)
    }
}

extension Shortcut {
    public static var empty: Shortcut {
        return Shortcut(keyCode: 0, modifierFlags: [], character: "")
    }
    
    public static var legacyShortcut: Shortcut {
        return Shortcut(keyCode: 21, modifierFlags: [.command], character: "4")
    }
}

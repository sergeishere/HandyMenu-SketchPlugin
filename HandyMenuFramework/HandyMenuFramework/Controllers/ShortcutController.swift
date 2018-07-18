//
//  ShortcutController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation

public protocol ShortcutControllerDelegate: class {
    func shortcutContoller(_ shortcutController: ShortcutController, didRecognize shortcut: Shortcut)
}

public class ShortcutController {
    
    // MARK: - Private Variables
    private var keyDownMonitor:Any?
    private var flagsChangeMonitor:Any?
    private var currentShortcut: Shortcut
    
    private var registeredShortcuts: Set<Int> = []
    
    // MARK: - Public Variables
    public weak var delegate: ShortcutControllerDelegate?
    
    // MARK: - Instance Lifecycle
    
    public init() {
        // Handling changing flags
        currentShortcut = Shortcut(commandIsPressed: false, optionIsPressed: false, controlIsPressed: false, shiftIsPressed: false, keyCode:0)
        
        flagsChangeMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged, handler: { [weak self] (event) -> NSEvent? in
            if let strongSelf = self {
                strongSelf.currentShortcut.commandIsPressed = event.modifierFlags.contains(.command)
                strongSelf.currentShortcut.optionIsPressed = event.modifierFlags.contains(.option)
                strongSelf.currentShortcut.controlIsPressed = event.modifierFlags.contains(.control)
                strongSelf.currentShortcut.shiftIsPressed = event.modifierFlags.contains(.shift)
            }
            
            return event
        })
        
        // Handling pressing keys
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] (event) -> NSEvent? in
            let keyCode = Int(event.keyCode)
            
            if let strongSelf = self {
                strongSelf.currentShortcut.keyCode = keyCode
                if strongSelf.registeredShortcuts.contains(strongSelf.currentShortcut.hashValue) {
                    strongSelf.delegate?.shortcutContoller(strongSelf, didRecognize: strongSelf.currentShortcut)
                    return nil
                }
            }
            return event
        }
        
    }
    
    public func register(shortcuts: [Shortcut]) {
        for shortcut in shortcuts {
            self.registeredShortcuts.insert(shortcut.hashValue)
        }
    }
    
    deinit {
        keyDownMonitor = nil
        flagsChangeMonitor = nil
    }
}

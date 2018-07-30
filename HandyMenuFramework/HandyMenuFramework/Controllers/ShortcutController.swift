//
//  ShortcutController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation
import os.log

public protocol ShortcutControllerDelegate: class {
    func shortcutController(_ shortcutController: ShortcutController, didRecognize shortcut: Shortcut, in event: NSEvent) -> NSEvent?
}

public class ShortcutController {
    
    // MARK: - Private Variables
    private var keyDownMonitor:Any?
    
    // MARK: - Public Variables
    public var currentShortcut = Shortcut()
    public weak var delegate: ShortcutControllerDelegate?
    
    // MARK: - Instance Lifecycle
    public init() {
        
    }
    
    public func start() {
        self.currentShortcut = Shortcut()
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] (event) -> NSEvent? in
            if let strongSelf = self, let delegate = strongSelf.delegate {
                strongSelf.currentShortcut.keyCode = Int(event.keyCode)
                strongSelf.currentShortcut.character = event.charactersIgnoringModifiers ?? ""
                strongSelf.currentShortcut.commandIsPressed = event.modifierFlags.contains(.command)
                strongSelf.currentShortcut.optionIsPressed = event.modifierFlags.contains(.option)
                strongSelf.currentShortcut.controlIsPressed = event.modifierFlags.contains(.control)
                strongSelf.currentShortcut.shiftIsPressed = event.modifierFlags.contains(.shift)
                return delegate.shortcutController(strongSelf, didRecognize: strongSelf.currentShortcut, in: event)
            }
            
            return event
        }
    }
    
    public func stop() {
        if let keyDownMonitor = self.keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
            self.keyDownMonitor = nil
        }
    }
}

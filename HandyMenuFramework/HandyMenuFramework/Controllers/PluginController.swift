//
//  HMPluginController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 10/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation
import AppKit
import os.log

@objc(HandyMenuPlugin) class PluginController:NSObject {
    
    // MARK: - Singletone instance
    @objc static let shared = PluginController()
    
    // MARK: - Private Properties
    private let dataController = PluginDataController()
    private let menuController = MenuController()
    private let shortcutController = ShortcutController()
    private var settingsWindowController = SettingsWindowController(windowNibName: NSNib.Name(rawValue: "SettingsWindowController"))
    
    
    // MARK: - Plugin Lifecycle
    private override init() {
        super.init()
        
        self.dataController.delegate = self
        self.shortcutController.delegate = self
        self.settingsWindowController.delegate = self
        
        self.dataController.loadData()
    }
    
    @objc public func wakeUp() {
        os_log("[Handy Menu] Has been woken up")
    }
    
    @objc public func showSettings() {
        settingsWindowController.showWindow(nil)
    }
    
}


// MARK: - PluginDataControllerDelegate
extension PluginController: PluginDataControllerDelegate {
    
    func dataController(_ dataController: PluginDataController, didUpdate data: PluginData) {
        self.shortcutController.start()
        self.menuController.configure(for: data.collections)
    }
    
}

// MARK: - ShortcutControllerDelegate
extension PluginController: ShortcutControllerDelegate {
    func shortcutContoller(_ shortcutController: ShortcutController, didRecognize shortcut: Shortcut, in event: NSEvent) -> NSEvent? {
        guard self.dataController.usedShortcuts.contains(shortcut.hashValue) else { return event }
        self.menuController.show(for: shortcut)
        return nil
    }
}

// MARK: - SettingsWindowControllerDelegate
extension PluginController: SettingsWindowControllerDelegate {
    func settingsWindowController(_ settingsWindowController: SettingsWindowController, didUpdate menuData: [MenuData]) {
        
    }
}

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

@objc(HandyMenu) class PluginController:NSObject {
    
    // MARK: - Singletone instance
    @objc static let shared = PluginController()
    
    // MARK: - Properties
//    private let settingsWindowController = HMSettingsWindowController()
    private let dataController = PluginDataController()
    private let menuController = MenuController()
    private let shortcutController = ShortcutController()
    
    private override init() {
        super.init()
        
        os_log("[Handy Menu] Init")
        self.dataController.delegate = self
        self.dataController.loadData()
        
        self.shortcutController.delegate = self

//        self.settingsWindowController = HMSettingsWindowController(nibName)
//        [settingsWindowController updatePlugins:[dataProvider getPluginsSchemes]];
//        [settingsWindowController updateUserCommands:[dataProvider getUserCommandsSchemes]];
//        [settingsWindowController setDelegate:self];
    }
    
    @objc public func wakeUp() {
        os_log("[Handy Menu] Configured")
    }

    @objc public func showSettings() {
        os_log("[Handy Menu] Showing the settings")
//        pluginController.showSettings()
    }
    
}


// MARK: - PluginDataControllerDelegate
extension PluginController: PluginDataControllerDelegate {
    
    func dataController(_ dataController: PluginDataController, didUpdate data: PluginData) {
        os_log("[Handy Menu] Data Provider updated schemes")
    }
    
}

// MARK: - ShortcutControllerDelegate
extension PluginController: ShortcutControllerDelegate {
    func shortcutContoller(_ shortcutController: ShortcutController, didRecognize shortcut: Shortcut) {
        menuController.show(for: shortcut)
    }
}

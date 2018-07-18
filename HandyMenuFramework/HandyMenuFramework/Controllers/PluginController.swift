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
        os_log("[Handy Menu] Has been woken up")
    }

    @objc public func showSettings() {
//        pluginController.showSettings()
    }
    
}


// MARK: - PluginDataControllerDelegate
extension PluginController: PluginDataControllerDelegate {
    
    func dataController(_ dataController: PluginDataController, didUpdate data: PluginData) {
        self.menuController.configure(for: data.collections)
    }
    
}

// MARK: - ShortcutControllerDelegate
extension PluginController: ShortcutControllerDelegate {
    func shortcutContoller(_ shortcutController: ShortcutController, didRecognize shortcut: Shortcut) {
        self.menuController.show(for: shortcut)
    }
}

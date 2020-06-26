//
//  HMPluginController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 10/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

@objc(HandyMenuPlugin) class PluginController:NSObject {
    
    // MARK: - Singletone instance
    @objc static let shared = PluginController()
    
    // MARK: - Private Properties
    private let settingsWindowController: SettingsWindowController
    private let dataController: DataController
    private let menuController: MenuController
    private let shortcutController: ShortcutController
    
    // MARK: - Plugin Lifecycle
    private override init() {
        self.settingsWindowController = SettingsWindowController(windowNibName: .settingsWindowController)
        self.dataController = DataController()
        self.menuController = MenuController()
        self.shortcutController = ShortcutController()
        super.init()
    }
    
    @objc public func configure() {
        self.settingsWindowController.delegate = self
        self.shortcutController.delegate = self
        self.dataController.delegate = self
        self.dataController.loadInstalledPluginsData()
        self.dataController.loadPluginData()
    }
    
    @objc public func showSettings() {
        self.settingsWindowController.showWindow(nil)
        shortcutController.stop()
    }
    
    @objc public func show(_ collection: String) {
        self.showSettings()
        self.settingsWindowController.showCollection(collection)
    }
    
    @objc public func importSettings() {
        self.dataController.importSettings()
    }
    
    @objc public func exportSettings() {
        self.dataController.exportSettings()
    }
    
}


// MARK: - PluginDataControllerDelegate
extension PluginController: DataControllerDelegate {
    
    func dataController(_ dataController: DataController, didUpdate data: PluginData) {
        self.shortcutController.start()
        self.menuController.configure(for: data.collections)
        self.settingsWindowController.configure(data.collections)
    }
    
    func dataController(_ dataController: DataController, didLoad installedPlugins: [InstalledPluginData]) {
        self.settingsWindowController.installedPlugins = installedPlugins
    }
}

// MARK: - ShortcutControllerDelegate
extension PluginController: ShortcutControllerDelegate {
    func shortcutController(_ shortcutController: ShortcutController, didRecognize shortcut: Shortcut, in event: NSEvent) -> NSEvent? {
        guard NSDocumentController.shared.documents.count > 0,
            self.dataController.usedShortcuts.contains(shortcut.hashValue) else { return event }
        self.menuController.show(for: shortcut)
        return nil
    }
}

// MARK: - SettingsWindowControllerDelegate
extension PluginController: SettingsWindowControllerDelegate {
    func settingsWindowController(_ settingsWindowController: SettingsWindowController, didUpdate menuData: [Collection]) {
        self.dataController.saveCollections(menuData)
    }
    
    func settingsWindowController(didClose settingsWindowController: SettingsWindowController) {
        self.shortcutController.start()
    }
}

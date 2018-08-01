//
//  DataProvider.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 10/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation
import AppKit
import os.log

public protocol PluginDataControllerDelegate: class {
    func dataController(_ dataController: PluginDataController, didUpdate data:PluginData)
    func dataController(_ dataController: PluginDataController, didLoad installedPlugins:[InstalledPluginData])
}

public class PluginDataController {
    
    // MARK: - Private Properties
    private var pluginData: PluginData?
    private var dataCaretaker = PluginDataCaretaker()
    
    // MARK: - Public Properties
    public var usedShortcuts: Set<Int> {
        if let shortcutHashes = pluginData?.collections.compactMap({$0.shortcut.hashValue}) {
            return Set(shortcutHashes)
        }
        return []
    }
    
    // MARK: - Public Properties
    public weak var delegate: PluginDataControllerDelegate?
    
    // MARK: - Object Lifecycle
    public init() {}
    
    // MARK: - Instance Methods
    public func loadPluginData(){
        self.pluginData = dataCaretaker.retrieve() ?? PluginData.empty
        delegate?.dataController(self, didUpdate: pluginData!)
    }
    
    public func saveCollections(_ collections: [MenuData]) {
        self.pluginData?.collections = collections
        // TODO: Implement this!!!
        self.delegate?.dataController(self, didUpdate: self.pluginData!)
    }
    
    public func loadInstalledPluginsData() {
        guard let installedPlugins = SketchAppBridge.sharedInstance().installedPlugins as? [String: NSObject] else { return }
        var installedPluginsData:[InstalledPluginData] = []
        
        for (pluginKey, pluginBundle) in installedPlugins {
            
            // Checking if the plugin exists and has name
            guard let pluginName = pluginBundle.value(forKey: "name") as? String else { continue }
            let pluginImage: NSImage? = pluginBundle.value(forKeyPath: "iconInfo.image") as? NSImage
            plugin_log("Image url: ", String(describing: pluginImage))
            var installedPluginData = InstalledPluginData(pluginName: pluginName, image: pluginImage, commands: [])
            
            // Checking if the plugin has commands
            guard let commandsDictionary = pluginBundle.value(forKey: "commands") as? [String: NSObject] else { continue }
            for (_, commandBundle) in commandsDictionary {
                // Command should have name, identifier and run handler
                if let hasRunHandler = commandBundle.value(forKey: "hasRunHandler") as? Bool, hasRunHandler == true,
                    let commandName = commandBundle.value(forKey: "name") as? String,
                    let commandID = commandBundle.value(forKey: "identifier") as? String {
                    
                    let installedPluginCommand = PluginCommandData(name: commandName, commandID: commandID, pluginName: pluginName, pluginID: pluginKey)
                    installedPluginData.commands.append(installedPluginCommand)
                }
            }
            installedPluginsData.append(installedPluginData)
        }
        installedPluginsData.sort { $0.pluginName < $1.pluginName }
        self.delegate?.dataController(self, didLoad: installedPluginsData)
    }
}

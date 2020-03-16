//
//  DataProvider.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 10/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import os.log

public protocol DataControllerDelegate: class {
    func dataController(_ dataController: DataController, didUpdate data:PluginData)
    func dataController(_ dataController: DataController, didLoad installedPlugins:[InstalledPluginData])
}

public class DataController {
    
    // MARK: - Private Properties
    private lazy var pluginData: PluginData = .empty
    private var installedPlugins: [InstalledPluginData] = []
    private var dataCaretaker = DataCaretaker()
    
    // MARK: - Public Properties
    public var usedShortcuts: Set<Int> {
        Set(pluginData.collections.compactMap({$0.shortcut.hashValue}))
    }
    
    // MARK: - Public Properties
    public weak var delegate: DataControllerDelegate?

    // MARK: - Instance Methods
    private func loadData(for retrievingResult: DataCaretaker.RetrievingResult) -> PluginData {
        switch retrievingResult {
        case .v5(let pluginData):
            return pluginData
        case .v4(let schemes):
            var newData = PluginData.empty
            var newItems: [CollectionItem] = []
            for scheme in schemes {
                guard let installedPlugins = SketchAppBridge.sharedInstance().installedPlugins as? [String:NSObject],
                    let pluginBundle = installedPlugins[scheme.pluginID],
                    let pluginName = pluginBundle.value(forKey: "name") as? String else { continue }
                let newItemData = Command(name: scheme.name, commandID: scheme.commandID, pluginName: pluginName, pluginID: scheme.pluginID)
                newItems.append(.command(newItemData))
            }
            newData.collections = [Collection(title: "Main Collection", shortcut: .legacyShortcut, items: newItems, autoGrouping: true)]
            return newData
        case .empty:
            return PluginData.empty
        }
    }
    
    public func loadPluginData() {
        pluginData = self.loadData(for: dataCaretaker.retrieve())
        pluginData.pluginVersion = PluginData.currentVersion
        pluginData.collections = filterCollections(pluginData.collections)
        delegate?.dataController(self, didUpdate: pluginData)
    }
    
    private func filterCollections(_ collections: [Collection]) -> [Collection] {
        
        // Preparing new array for filtered collections
        var filteredCollections: [Collection] = []
        
        // Filetering
        for unfilteredCollection in collections {
            var newCollection = unfilteredCollection
            newCollection.items = unfilteredCollection.items.filter({(collectionItem) -> Bool in
                switch collectionItem {
                case .separator:
                    return true
                case .command(let commandData):
                    return SketchAppBridge.sharedInstance().isExists(commandData.pluginID, with: commandData.commandID)
                }
            })
            filteredCollections.append(newCollection)
        }
        return filteredCollections
    }
    
    public func saveCollections(_ collections: [Collection]) {
        pluginData.collections = collections
        guard dataCaretaker.save(pluginData) else { return }
        delegate?.dataController(self, didUpdate: pluginData)
    }
    
    public func loadInstalledPluginsData() {
        guard let installedPlugins = SketchAppBridge.sharedInstance().installedPlugins as? [String: NSObject] else { return }
        var installedPluginsData:[InstalledPluginData] = []
        
        for (pluginKey, pluginBundle) in installedPlugins {
            // Checking if the plugin exists and has name
            guard let pluginName = pluginBundle.value(forKey: "name") as? String,
                pluginName != "Handy Menu" else { continue }
            let pluginImage: NSImage? = pluginBundle.value(forKeyPath: "iconInfo.image") as? NSImage
            var installedPluginData = InstalledPluginData(pluginName: pluginName, image: pluginImage, commands: [])
            
            // Checking if the plugin has commands
            guard
                let commandsDictionary = pluginBundle.value(forKey: "commands") as? [String: NSObject]
                else { continue }
            
            for (_, commandBundle) in commandsDictionary {
                // Command should have name, identifier and run handler
                if let hasRunHandler = commandBundle.value(forKey: "hasRunHandler") as? Bool, hasRunHandler == true,
                    let commandName = commandBundle.value(forKey: "name") as? String,
                    let commandID = commandBundle.value(forKey: "identifier") as? String {
                    
                    let installedPluginCommand = Command(name: commandName, commandID: commandID, pluginName: pluginName, pluginID: pluginKey)
                    installedPluginData.commands.append(installedPluginCommand)
                }
            }
            installedPluginsData.append(installedPluginData)
        }
        self.installedPlugins = installedPluginsData
        installedPluginsData.sort { $0.pluginName < $1.pluginName }
        self.delegate?.dataController(self, didLoad: installedPluginsData)
    }
    
    public func exportSettings() {
        os_log("Exporting HandyMenu settings", log: .default)
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "collections.handymenu"
        savePanel.level = .modalPanel
        savePanel.allowedFileTypes = ["handymenu"]
        savePanel.begin { [weak self] response in
            guard let self = self,
                response == .OK,
                let fileURL = savePanel.url,
                let data = try? JSONEncoder().encode(self.pluginData) else { return }
            do {
                try data.write(to: fileURL)
            } catch {
                os_log("Couldn't export HandyMenu collections. %@",
                       log: .default, type: .error, error.localizedDescription)
            }
        }
    }
    
    public func importSettings() {
        os_log("Importing HandyMenu settings", log: .default)
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["handymenu"]
        openPanel.level = .modalPanel
        openPanel.nameFieldLabel = "Choose file with HandyMenu collections"
        openPanel.begin { [weak self] response in
            guard let self = self,
                response == .OK,
                let fileURL = openPanel.url
                else { return }
            do {
                let data = try Data(contentsOf: fileURL)
                let importedPluginData = try JSONDecoder().decode(PluginData.self, from: data)
                let filteredCollections = self.filterCollections(importedPluginData.collections)
                self.pluginData.userID = importedPluginData.userID
                self.saveCollections(filteredCollections)
                self.delegate?.dataController(self, didUpdate: self.pluginData)
            } catch {
                os_log("Couldn't import HandyMenu collections. %@",
                       log: .default, type: .error, error.localizedDescription)
                NSApplication.shared.keyWindow?.presentError(error)
            }
        }
    }
}

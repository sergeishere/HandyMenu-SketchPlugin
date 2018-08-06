//
//  DataProvider.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 10/06/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public protocol DataControllerDelegate: class {
    func dataController(_ dataController: DataController, didUpdate data:PluginData)
    func dataController(_ dataController: DataController, didLoad installedPlugins:[InstalledPluginData])
}

public class DataController {
    
    // MARK: - Private Properties
    private var pluginData: PluginData?
    private var installedPlugins: [InstalledPluginData] = []
    private var dataCaretaker = DataCaretaker()
    
    // MARK: - Public Properties
    public var usedShortcuts: Set<Int> {
        if let shortcutHashes = pluginData?.collections.compactMap({$0.shortcut.hashValue}) {
            return Set(shortcutHashes)
        }
        return []
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
    
    public func loadPluginData(){
        self.pluginData = self.loadData(for: dataCaretaker.retrieve())
        self.pluginData?.pluginVersion = PluginData.currentVersion
        self.filterCollections()
        delegate?.dataController(self, didUpdate: pluginData!)
    }
    
    private func filterCollections() {
        guard let pluginData = self.pluginData else { return }
        
        var filteredCollections: [Collection] = [] // Preparing new array for filtered collections
        for unfilteredCollection in pluginData.collections {
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
        self.pluginData?.collections = filteredCollections
    }
    
    public func saveCollections(_ collections: [Collection]) {
        self.pluginData?.collections = collections
        guard let pluginData = self.pluginData,
            self.dataCaretaker.save(pluginData) else { return }
        self.delegate?.dataController(self, didUpdate: pluginData)
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
            guard let commandsDictionary = pluginBundle.value(forKey: "commands") as? [String: NSObject] else { continue }
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
}

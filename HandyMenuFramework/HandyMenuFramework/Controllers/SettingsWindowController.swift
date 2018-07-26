//
//  SettingsWindowController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa
import os.log

public protocol SettingsWindowControllerDelegate: class {
    func settingsWindowController(_ settingsWindowController: SettingsWindowController, didUpdate menuData:[MenuData])
}

public class SettingsWindowController: NSWindowController {
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var installedPluginsCollectionView: NSCollectionView!
    
    private let commandHeight:CGFloat = 20.0
    
    // MARK: - Public Properties
    public weak var delegate: SettingsWindowControllerDelegate?
    public var installedPlugins: [InstalledPluginData] = []
    
    // MARK: - Lifecycle
    override public func windowDidLoad() {
        super.windowDidLoad()
        
        self.installedPluginsCollectionView.dataSource = self
        self.installedPluginsCollectionView.delegate = self
        
    }
}

// MARK: - NSCollectionViewDataSource
extension SettingsWindowController: NSCollectionViewDataSource {
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return installedPlugins.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return installedPlugins[section].commands.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let collectionViewItem = installedPluginsCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CommandCollectionViewItem"), for: indexPath)
        let command = installedPlugins[indexPath.section].commands[indexPath.item]
        collectionViewItem.textField?.stringValue = "\(command.name)"
        return collectionViewItem
    }
}

// MARK: - NSCollectionViewDelegate
extension SettingsWindowController: NSCollectionViewDelegate {
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSMakeSize(collectionView.bounds.width, self.commandHeight)
    }
}

// MARK: - Actions Handling
extension SettingsWindowController {
    
    @IBAction func save(_ sender: Any) {
        self.delegate?.settingsWindowController(self, didUpdate: [])
        self.window?.close()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.window?.close()
    }
    
    @IBAction func github(_ sender: Any) {
        guard let githubPageUrl = URL(string: "https://github.com/sergeishere/HandyMenu-SketchPlugin") else { return }
        NSWorkspace.shared.open(githubPageUrl)
    }
    
}
